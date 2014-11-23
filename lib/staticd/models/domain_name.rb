require "staticd/models/base"

module Staticd
  module Models
    class DomainName < Staticd::Models::Base
      include DataMapper::Resource

      property :name, String, key: true, unique: true

      belongs_to :site
    end
  end
end
