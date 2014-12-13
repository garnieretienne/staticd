require "test_helper"
require "staticd/cache_engine"

class CacheEngineTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    @resource_url = fixtures_path("sites/hello_world/index.html")
  end

  def test_it_should_cache_a_resource
    local_path = "/i/am/here.html"
    Dir.mktmpdir do |cache_root|
      cache_engine = Staticd::CacheEngine.new(cache_root)
      cache_engine.cache(local_path, @resource_url)
      assert File.exist?(cache_root + local_path)
      assert cache_engine.cached?(local_path)
    end
  end
end
