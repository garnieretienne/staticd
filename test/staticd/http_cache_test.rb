require "test_helper"
require "staticd/http_cache"

class HTTPCacheTest < Minitest::Unit::TestCase
  include TestHelper

  def env_app
    Proc.new { |env| [200, {}, [env]] }
  end

  def app
    tmp = Dir.mktmpdir
    Staticd::HTTPCache.new(tmp, env_app)
  end

  def setup
    init_fixtures
  end

  def test_script_name_should_be_altered_to_include_site_name
    first_route = sample_resource.routes.first
    get first_route.path
    assert_includes(
      last_response.body,
      "\"SCRIPT_NAME\"=>\"/#{sample_site.name}/" +
        "#{sample_site.releases.last.tag}\""
    )
  end

  def test_should_modify_the_path_info_if_root_required
    get "/"
    assert_includes(
      last_response.body,
      "\"PATH_INFO\"=>\"/index.html\""
    )
  end
end
