require "test_helper"
require "open-uri"
require "staticd/datastores/s3"
require "staticd/datastores/datastore_test_interface"

class DatastoreS3Test < Minitest::Unit::TestCase
  include TestHelper

  if ENV["TESTING_S3_URL"] &&
     ENV["TESTING_AWS_ACCESS_KEY_ID"] &&
     ENV["TESTING_AWS_SECRET_ACCESS_KEY"]
  then
    include DatastoreTestInterface

    def setup
      uri = URI(ENV["TESTING_S3_URL"])
      @datastore = Staticd::Datastores::S3.new(
        host: uri.host,
        username: ENV["TESTING_AWS_ACCESS_KEY_ID"],
        password: ENV["TESTING_AWS_SECRET_ACCESS_KEY"]
      )
    end

    def test_it_should_store_file_and_return_an_url
      resource_path = fixtures_path("sites/hello_world/index.html")
      resource_url = @datastore.put(resource_path)
      assert open(resource_url) { |file| file.read }
      assert @datastore.exist?(resource_path)
    end
  end
end
