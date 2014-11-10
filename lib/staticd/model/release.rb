module Staticd
  module Model
    class Release
      include DataMapper::Resource
      include Staticd::Model::Serializer

      property :id, Serial, unique: true
      property :tag, String, required: true

      belongs_to :site
      has n, :release_maps, constraint: :destroy
      has n, :resources, through: :release_maps
    end
  end
end
