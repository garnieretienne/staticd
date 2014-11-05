require "test_helper"
require "staticd/datastore/local"

class DatastoreLocalTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    @datastore = Staticd::Datastore::Local.new path: Dir.mktmpdir
  end

  def test_it_should_store_file_and_return_an_url
    archive_path = fixtures_path("files/mywebsite.fr.tar.gz")
    archive_url = @datastore.put archive_path
    assert open(archive_url){|file| File.exist? file}
  end
end
