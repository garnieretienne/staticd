module Staticd
  module Model
    class Site
      include DataMapper::Resource
      include Staticd::Model::Serializer

      property :name, String, key: true, unique: true

      has n, :releases
      has n, :domain_names
    end
  end
end
