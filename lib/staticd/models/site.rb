require "staticd/models/base"

module Staticd
  module Models
    class Site < Staticd::Models::Base
      include DataMapper::Resource

      property :name, String, key: true, unique: true

      has n, :releases, constraint: :destroy
      has n, :domain_names, constraint: :destroy
    end
  end
end
