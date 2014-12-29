require "api_auth"
require "base64"

# Rack middleware to authenticate requests using the HMAC-SHA1 protocol.
#
# It take a Proc as argument to find the entity secret key using the access id
# provided in the request. Once returned, the entity secret key is compared
# with secret key provided by the the request.
# Unless the two keys match, a 401 Unauthorized HTTP Error page is sent.
#
# Options:
# * environment: bypass authentication if set to "test"
# * except: list of HTTP paths with no authentication required
#
# Example:
#   use Rack::Auth::HMAC do |request_access_id|
#     return entity_secret_key if request_access_id == entity_access_id
#   end
class Rack::Auth::HMAC

  def initialize(app, options={}, &block)
    @app = app
    options[:except] ||= []
    @options = options
    @block = block
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    return @app.call(env) if @options[:except].include?(env["PATH_INFO"])

    env = fix_content_type(env)

    request = Rack::Request.new(env)
    access_id = ApiAuth.access_id(request)
    secret_key = @block.call(access_id)

    if ApiAuth.authentic?(request, secret_key)
      status, headers, response = @app.call(env)
    else
      send_401(content_type: env["HTTP_ACCEPT"], ip: request.ip)
    end
  end

  private

  # Fix an issue with the HMAC canonical string calculation.
  #
  # Ensure the request Content-Type is not set to anything when a GET or
  # DELETE method is used. Sinatra (or Rack) seems to set it to 'plain/text'
  # when not specified.
  def fix_content_type(env)
    if ["GET", "DELETE"].include?(env["REQUEST_METHOD"])
      env["CONTENT_TYPE"] = ""
    end
    env
  end

  def send_401(content_type: "text/plain", ip: nil)
    message = "Valid access ID and secret key are required."
    snonce = Base64.encode64(Time.now.to_s + ip)

    body =
      case content_type
      when "application/json" then %({"error": "#{message}"})
      when "text/html" then "<h1>#{message}</h1>"
      else
        message
      end

    headers = {
      "Content-Type" => content_type,
      "WWW-Authenticate" => %(HMACDigest realm="#{message}" snonce="#{snonce}")
    }

    Rack::Response.new(body, 401, headers)
  end
end
