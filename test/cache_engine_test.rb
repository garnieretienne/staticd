require "test_helper"
require "staticd/cache_engine"

class CacheEngineTest < MiniTest::Test
  include TestHelper

  def setup
    @archive_url = fixtures_path("files/mywebsite.fr.tar.gz")
    Staticd::CacheEngine.reset!
  end

  def test_it_should_cache_the_content_of_an_archive
    local_path = Staticd::CacheEngine.cache @archive_url
    assert File.directory? local_path
    refute Dir["#{local_path}/*"].empty?
    assert_equal local_path, Staticd::CacheEngine.cached?(@archive_url)
    assert Staticd::CacheEngine.purge @archive_url
    refute File.directory? local_path
    refute Staticd::CacheEngine.cached? @archive_url
    refute Staticd::CacheEngine.purge @archive_url
  end
end
