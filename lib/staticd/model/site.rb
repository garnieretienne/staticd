module Staticd
  module Model
    class Site
      include DataMapper::Resource
      include Staticd::Model::Serializer

      property :name, String, key: true, unique: true

      has n, :releases, constraint: :destroy
      has n, :domain_names, constraint: :destroy
    end
  end
end
