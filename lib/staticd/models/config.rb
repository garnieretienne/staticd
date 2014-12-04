require "staticd/models/config"

module Staticd
  module Models
    class StaticdConfig
      include DataMapper::Resource

      property :name, String, key: true, unique: true
      property :value, String
    end
  end
end
