require "test_helper"
require "staticd/cache_engine"

class CacheEngineTest < MiniTest::Unit::TestCase
  include TestHelper

  def setup
    @archive_url = fixtures_path("files/mywebsite.fr.tar.gz")
    CacheEngine.reset!
  end

  def test_it_should_cache_the_content_of_an_archive
    local_path = CacheEngine.cache @archive_url
    assert File.directory? local_path
    refute Dir["#{local_path}/*"].empty?
    assert_equal local_path, CacheEngine.cached?(@archive_url)
    assert CacheEngine.purge @archive_url
    refute File.directory? local_path
    refute CacheEngine.cached? @archive_url
    refute CacheEngine.purge @archive_url
  end
end
