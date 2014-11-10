require "test_helper"
require "staticd/datastore/s3"
require "datastore/store_interface"

class DatastoreS3Test < Minitest::Unit::TestCase
  include TestHelper
  include Test::StoreInterface

  def setup
    @datastore = Staticd::Datastore::S3.new({})
  end
end
