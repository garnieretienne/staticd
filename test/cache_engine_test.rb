require "test_helper"
require "staticd/cache_engine"

class CacheEngineTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    @archive_url = fixtures_path("files/mywebsite.fr.tar.gz")
  end

  def test_it_should_cache_the_content_of_an_archive
    local_path = "/i/am/here.html"
    Dir.mktmpdir do |cache_root|
      Staticd::CacheEngine.cache(
        cache_root,
        local_path,
        @archive_url
      )
      assert File.exist? cache_root + local_path
      assert Staticd::CacheEngine.cached? cache_root, local_path
    end
  end
end
