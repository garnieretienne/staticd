require "test_helper"
require "staticd/http_server"

class HTTPServerTest < MiniTest::Test
  include TestHelper

  def app
    Staticd::HTTPServer.new
  end

  def setup
    init_fixtures
  end

  def test_get_index_of_test_site
    get "/"
    assert last_response.ok?
    assert_equal "<h1>Hello World</h1>", last_response.body.strip
  end

  def test_get_index_file_of_test_site
    get "/index.html"
    assert last_response.ok?
    assert_equal "<h1>Hello World</h1>", last_response.body.strip
  end

  def test_get_not_found_for_test_site
    get "/do_not_exist"
    refute last_response.ok?
  end
end
