module Staticd
  module Model
    class Release
      include DataMapper::Resource
      include Staticd::Model::Serializer

      property :id, Serial, unique: true
      property :tag, String, required: true
      property :url, String, required: true, length: 1..200

      belongs_to :site
    end
  end
end
