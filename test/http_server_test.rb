require "test_helper"
require "staticd/http_server"

class HTTPServerTest < Minitest::Unit::TestCase
  include TestHelper

  def app
    Staticd::HTTPServer.new fixtures_path('sites/hello_world')
  end

  def setup
    init_fixtures
  end

  def test_get_index_file_of_test_site
    get "/index.html"
    assert last_response.ok?
    assert_includes last_response.body, "<h1>Hello World</h1>"
  end

  def test_get_not_found_for_test_site
    get "/do_not_exist"
    refute last_response.ok?
  end
end
