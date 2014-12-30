require "staticd/models/base"
require "staticd/config"

module Staticd
  module Models
    class Site < Staticd::Models::Base
      include DataMapper::Resource

      property :name, String, key: true, unique: true

      has n, :releases, constraint: :destroy
      has n, :domain_names, constraint: :destroy

      def url
        if domain_names.any?
          url = "http://#{domain_names.first.name}"
          url += ":#{Staticd::Config[:port]}" if Staticd::Config[:port] != 80
        end
      end

      def to_s
        name
      end

      def to_h(*args)
        hash = super *args
        hash["url"] = url
        hash
      end
    end
  end
end
