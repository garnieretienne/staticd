require "singleton"
require "uri"

# Load datastores libraries.
Dir["#{File.dirname(__FILE__)}/datastores/*.rb"].each do |datastore_library|
  require datastore_library
end

module Staticd

  # Load the corresponding datastore driver from an URL.
  #
  # This class use an URL to choose wich datastore library to use.
  # It create a datastore instance with the correct driver and proxies its
  # calls to it.
  # It use the URL scheme to guess wich datastore library to use.
  #
  # Example:
  #   Staticd::Datastore.setup("s3://[...]")   # Staticd::Datastores::S3
  #   Staticd::Datastore.setup("local:/[...]") # Staticd::Datastores::Local
  #   Staticd::Datastore.put(file_path)
  class Datastore
    include Singleton

    def self.setup(url)
      instance.setup(url)
    end

    def self.put(file_path)
      instance.put(file_path)
    end

    def self.exist?(file_path)
      instance.exist?(file_path)
    end

    def setup(url)
      @uri = URI(url)
    end

    def put(file_path)
      datastore.put(file_path)
    end

    def exist?(file_path)
      datastore.exist?(file_path)
    end

    private

    def datastoreClass
      @datastoreClass ||= Datastores.const_get(@uri.scheme.capitalize)
    end

    def datastore
      @datastore ||= datastoreClass.new(
        host: @uri.host,
        path: @uri.path,
        username: @uri.user,
        password: @uri.password
      )
    end
  end
end
