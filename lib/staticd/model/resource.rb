module Staticd
  module Model
    class Resource
      include DataMapper::Resource
      include Staticd::Model::Serializer

      property :id, Serial, unique: true
      property :url, String, required: true, length: 1..200

      has n, :release_maps
      has n, :releases, through: :release_maps
    end
  end
end
