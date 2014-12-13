require "test_helper"
require "staticd/datastores/local"
require "staticd/datastores/datastore_test_interface"

class DatastoreLocalTest < Minitest::Unit::TestCase
  include TestHelper
  include DatastoreTestInterface

  def setup
    @datastore = Staticd::Datastores::Local.new(path: Dir.mktmpdir)
  end

  def test_it_should_store_file_and_return_an_url
    resource_path = fixtures_path("sites/hello_world/index.html")
    resource_url = @datastore.put(resource_path)
    assert open(resource_url) { |file| File.exist?(file) }
    assert @datastore.exist?(resource_path)
  end
end
