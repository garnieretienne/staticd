module Staticd
  module Model
    class DomainName
      include DataMapper::Resource

      property :name, String, key: true, unique: true

      belongs_to :site
    end
  end
end
