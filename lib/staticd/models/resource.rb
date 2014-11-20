module Staticd
  module Models
    class Resource
      include DataMapper::Resource
      include Staticd::Models::Serializer

      property :sha1, String, key: true, unique: true
      property :url, String, required: true, length: 1..200

      has n, :routes
      has n, :releases, through: :routes
    end
  end
end
