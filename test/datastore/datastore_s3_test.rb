require "test_helper"
require "staticd/datastores/s3"
require "datastore/datastore_interface"

class DatastoreS3Test < Minitest::Unit::TestCase
  include TestHelper
  include Test::DatastoreInterface

  def setup
    @datastore = Staticd::Datastores::S3.new({})
  end
end
