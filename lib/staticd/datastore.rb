require "uri"
require "staticd/datastores/local"
require "staticd/datastores/s3"

module Staticd
  class Datastore

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
      @datastoreClass ||= Datastores.const_get(@uri.scheme.capitalize)
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
