# frozen_string_literal: true

require 'bundler'
Bundler.require
require 'sinatra/base'
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].sort.each { |file| require file }
Dir["#{File.dirname(__FILE__)}/stores/*.rb"].sort.each { |file| require file }

class Budgerigar < Sinatra::Base
  VALID_PARAMS = %w[actor film].freeze
  RESPONSE_KEYS = { 'actor' => 'films', 'film' => 'actors' }.freeze

  before do
    content_type :json

    unless params.keys.any? { |key| VALID_PARAMS.include?(key) }
      halt 400, { error: "Error, invalid parameter, valid parameters: #{VALID_PARAMS}" }.to_json
    end

    halt 400, { error: 'Error, only one parameter supported' }.to_json if params.keys.length > 1
  end

  get '/' do
    key = params.keys.first
    cached_resp = RequestStore.instance.get(key, params[key])
    return { RESPONSE_KEYS[key] => cached_resp }.to_json if cached_resp

    begin
      resp = DbpediaClient.get(key, params[key])

      cached_resp = { RESPONSE_KEYS[key] => resp }
      RequestStore.instance.set(key, cached_resp)
      cached_resp.to_json
    rescue DbpediaClient::RequestError, Faraday::ConnectionFailed
      halt 500, { error: 'Sorry there was an error fetching your query, please try again' }
    end
  end
end
