require "rest_client"
require "api-auth"
require "json"

module Staticdctl

  class RESTClient

    def initialize(url, hmac={})
      @url = url
      @access_id = hmac[:access_id] || ""
      @secret_key = hmac[:secret_key] || ""
    end

    def call(method, path, req_data=nil, &block)
      headers = {}
      headers["Accept"] = "application/json"
      headers["Content-Type"] = "application/json" if req_data
      payload = req_data ? req_data.to_json : nil
      request = RestClient::Request.new(
        url: "#{@url}#{path}",
        method: method,
        headers: headers,
        payload: payload
      )

      send_request request, block
    end

    def send_file(path, file, &block)
      headers = {
       "Accept" => "application/json",
       "Content-Type" => "multipart/form-data"
      }
      request = RestClient::Request.new(
        url: "#{@url}#{path}",
        method: :post,
        headers: headers,
        payload: {file: file}
      )

      send_request request, block
    end

    private

    def send_request(request, procedure)
      signed_request = ApiAuth.sign!(request, @access_id, @secret_key)

      signed_request.execute do |response, request, result|
        res_data = JSON.parse(response.to_s) unless response.to_s.empty?
        case response.code
        when 200
          procedure.call res_data
        when 204
          procedure.call
        when 403
          raise res_data['error']
        when 401
          raise res_data['error']
        else
          raise "Server returned an '#{response.code}' status code"
        end
      end
    end
  end
end
