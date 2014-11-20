module Staticd
  module Models
    class DomainName
      include DataMapper::Resource
      include Staticd::Models::Serializer

      property :name, String, key: true, unique: true

      belongs_to :site
    end
  end
end
