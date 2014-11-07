require "uri"
require "staticd/datastore/local"
require "staticd/datastore/s3"

module Staticd
  class Store

    def initialize(url)
      @uri = URI(url)
    end

    def put(file_path)
      datastore.put file_path
    end

    def exist?(file_path)
      datastore.exist? file_path
    end

    private

    def datastoreClass
      @datastoreClass ||= Datastore.const_get(@uri.scheme.capitalize)
    end

    def datastore
      @datastore ||= datastoreClass.new({
        host: @uri.host,
        path: @uri.path,
        username: @uri.user,
        password: @uri.password
      })
    end
  end
end
