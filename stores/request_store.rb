# frozen_string_literal: true

require 'singleton'

class RequestStore
  include Singleton

  def get(parent_key, key)
    store.dig(parent_key, key)
  end

  def set(key, value)
    if store[key]
      store[key].merge!(value)
    else
      store[key] = value
    end
  end

  def store
    @store ||= {}
  end
end
