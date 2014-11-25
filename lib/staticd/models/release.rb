require "staticd/models/base"

module Staticd
  module Models
    class Release < Staticd::Models::Base
      include DataMapper::Resource

      property :id, Serial, unique: true
      property :tag, String, required: true

      belongs_to :site
      has n, :routes, constraint: :destroy
      has n, :resources, through: :routes

      def to_s
        tag
      end
    end
  end
end
