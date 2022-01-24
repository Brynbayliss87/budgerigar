# frozen_string_literal: true

class DbpediaClient
  class RequestError < StandardError; end

  BASE_URL = 'https://dbpedia.org/sparql?query='
  COMMON_QUERIES = '&format=json&timeout=30000'

  def self.get(key, value)
    case key
    when 'actor'
      uri = BASE_URL + actor_query(value) + COMMON_QUERIES
    when 'film'
      uri = BASE_URL + film_query(value) + COMMON_QUERIES
    end
    resp = Faraday.get(uri)
    raise RequestError unless resp.success?

    parse_response(resp.body)
  end

  def self.actor_query(actor)
    "SELECT ?res WHERE { ?res rdf:type dbo:Film .?res dbo:starring dbr:#{actor} .}"
  end

  def self.film_query(film)
    "SELECT ?res WHERE { <http://dbpedia.org/resource/#{film}> <http://dbpedia.org/ontology/starring> ?res}"
  end

  def self.parse_response(resp)
    results = JSON.parse(resp)['results']['bindings'].map { |r| r['res']['value'] }
    results.map { |r| r.split('/') }.map(&:last)
  end

  private_class_method :actor_query, :film_query, :parse_response
end
