require "test_helper"
require "staticd/datastore/local"
require "base64"

class DatastoreLocalTest < MiniTest::Test
  include TestHelper

  def test_it_should_store_file_and_return_an_url
    archive_path = fixtures_path("files/mywebsite.fr.tar.gz")
    archive_url = Staticd::Datastore::Local.put archive_path
    assert open(archive_url){|file| File.exist? file}
  end

  def test_it_should_store_base64_and_return_an_url
    archive_path = fixtures_path("files/mywebsite.fr.tar.gz")
    base64 = Base64.encode64 File.read(archive_path)
    archive_url = Staticd::Datastore::Local.put_base64 base64
    assert open(archive_url){|file| File.exist? file}
  end
end
