require "api_auth"
require "base64"

# Rack middleware to authenticate requests usin the HMAC-SHA1 protocol
class Rack::Auth::HMAC

  def initialize(app, rack_env=ENV["RACK_ENV"], &block)
    @app = app
    @rack_env = rack_env
    @block = block
  end

  def call(env)

    # Fix an issue with the HMAC canonical string calculation:
    # Ensure the request Content-Type is not set to nothing when a GET or DELETE
    # method is used as Sinatra or Rack seems to set it to 'plain/text' when not
    # specified.
    env["CONTENT_TYPE"] = "" if ["GET", "DELETE"].include? env["REQUEST_METHOD"]

    return @app.call(env) if @rack_env == "test"
    request = Rack::Request.new(env)
    access_id = ApiAuth.access_id(request)
    secret_key = @block.call(access_id)

    if ApiAuth.authentic?(request, secret_key)
      status, headers, response = @app.call(env)
    else
      accept = env["HTTP_ACCEPT"] || "text/plain"
      realm = "Valid ACCESS ID and SECRET KEY required."
      snonce = Base64.encode64(Time.now.to_s + request.ip)
      headers = {
        "WWW-Authenticate" =>
          "HMACDigest realm=\"#{realm}\" snonce=\"#{snonce}\"",
        "Content-Type" => accept
      }
      body = case accept
        when "application/json"
          "{\"error\": \"#{realm}\"}"
        when "text/html"
          "<h1>#{realm}</h1>"
        else
          realm
      end
      [401, headers, [body]]
    end
  end
end
