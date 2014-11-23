require "staticd/models/base"

module Staticd
  module Models
    class Resource < Staticd::Models::Base
      include DataMapper::Resource

      property :sha1, String, key: true, unique: true
      property :url, String, required: true, length: 1..200

      has n, :routes
      has n, :releases, through: :routes
    end
  end
end
