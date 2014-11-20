module Staticd
  module Models
    class Release
      include DataMapper::Resource
      include Staticd::Models::Serializer

      property :id, Serial, unique: true
      property :tag, String, required: true

      belongs_to :site
      has n, :routes, constraint: :destroy
      has n, :resources, through: :routes
    end
  end
end
