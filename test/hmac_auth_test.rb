require "test_helper"
require "rack/auth/hmac"
require "api-auth"

class HMACAuthTest < MiniTest::Test
  include TestHelper

  def setup
    @access_id = "test"
    @secret_key = "nBSy6jWj+77M+t76CEqMLVvP/L62KNNPOcSfdsIBWoRmRP4gMhVJoNJx3" +
    "Y9xd5Mc2LdvHUNTtPDWIK+jvJZN1A=="
  end

  def app
    hello = Proc.new {|env| [200, {}, ['Hello World']]}
    Rack::Auth::HMAC.new(hello, :hmac_test){|access_id| @secret_key}
  end

  def test_accessing_without_key
    get "/"
    refute last_response.ok?
  end

  def test_should_return_401_json
    get "/", {}, {"HTTP_ACCEPT" => "application/json"}
    assert_equal "application/json", last_response.headers["Content-Type"]
  end

  def test_should_return_401_html
    get "/", {}, {"HTTP_ACCEPT" => "text/html"}
    assert_equal "text/html", last_response.headers["Content-Type"]
  end

  def test_should_return_401_text
    get "/", {}, {"HTTP_ACCEPT" => "text/plain"}
    assert_equal "text/plain", last_response.headers["Content-Type"]
  end

  def test_accessing_with_correct_secret_key
    request = Rack::Request.new({
      "REQUEST_METHOD" => "GET",
      "SCRIPT_NAME" => "",
      "PATH_INFO" => "/",
      "QUERY_STRING" => "",
      "SERVER_NAME" => "example.org",
      "SERVER_PORT" => "80"
    })
    signed_request = ApiAuth.sign!(request, @access_id, @secret_key)
    status, = app.call(signed_request.env)
    assert_equal 200, status
  end
end
