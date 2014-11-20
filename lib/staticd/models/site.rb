module Staticd
  module Models
    class Site
      include DataMapper::Resource
      include Staticd::Models::Serializer

      property :name, String, key: true, unique: true

      has n, :releases, constraint: :destroy
      has n, :domain_names, constraint: :destroy
    end
  end
end
