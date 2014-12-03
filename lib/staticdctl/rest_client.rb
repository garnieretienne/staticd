require "rest_client"
require "api-auth"
require "json"

module Staticdctl

  # Simple REST client library with HMAC authentication.
  #
  # Support for remote call on JSON REST API.
  #
  # Example:
  #   client = Staticdctl::RESTCLient.new(
  #     url: "http://api.domain.tld/v1",
  #     access_id: 1000,
  #     secret_key: "youshallnotpass"
  #   )
  #   client.call(:get, "/resources") { |response| puts response }
  class RESTClient

    def initialize(url, hmac={})
      @url = url
      @access_id = hmac[:access_id] || ""
      @secret_key = hmac[:secret_key] || ""
    end

    # Call a remote REST API action.
    #
    # Example:
    #   client.call(:post, "/posts", {text: "hello_world"}) do |response|
    #     puts response
    #   end
    def call(method, path, req_data=nil, &block)
      headers = {
        "Accept" => "application/json"
      }
      headers["Content-Type"] = "application/json" if req_data
      payload = req_data ? req_data.to_json : nil
      request = RestClient::Request.new(
        url: @url + path,
        method: method,
        headers: headers,
        payload: payload
      )
      send_request(request, block)
    end

    # Send files using the HTTP multipart/form-data content-type.
    #
    # Example:
    #   client.send_files("/attachments", {first: file1, second: file2})
    def send_files(path, files, &block)
      headers = {
       "Accept" => "application/json",
       "Content-Type" => "multipart/form-data"
      }
      request = RestClient::Request.new(
        url: @url + path,
        method: :post,
        headers: headers,
        payload: files,
        timeout: -1
      )
      send_request(request, block)
    end

    private

    def send_request(request, &block)
      signed_request = ApiAuth.sign!(request, @access_id, @secret_key)
      signed_request.execute do |response, request, result|
        res_data = JSON.parse(response.to_s) unless response.to_s.empty?
        case response.code
        when 200
          block.call(res_data)
        when 204
          block.call
        when 403
          raise res_data["error"]
        when 401
          raise res_data["error"]
        else
          raise "Server returned an '#{response.code}' status code."
        end
      end
    end
  end
end
