require "staticd/models/base"

module Staticd
  module Models
    class Route < Staticd::Models::Base
      include DataMapper::Resource

      property :id, Serial, unique: true
      property :path, String, required: true

      belongs_to :release
      belongs_to :resource

      def to_s
        path
      end
    end
  end
end
