require "uri"
require "staticd/datastore/local"
require "staticd/datastore/s3"

module Staticd
  class Store

    def initialize(url)
      @uri = URI(url)
    end

    def put(file_path)
      datastoreClass = Datastore.const_get(@uri.scheme.capitalize)
      datastore = datastoreClass.new({
        host: @uri.host,
        path: @uri.path,
        username: @uri.user,
        password: @uri.password
      })
      datastore.put file_path
    end
  end
end
