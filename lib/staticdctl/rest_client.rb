require "rest_client"
require "json"

module Staticdctl

  class RESTClient

    def initialize(url)
      @url = url
    end

    def call(method, path, req_data=nil, &block)
      json_req_data = req_data ? req_data.to_json : nil
      req_args = ["#{@url}#{path}"]
      req_args << req_data.to_json if req_data
      req_opts = {accept: :json}
      req_opts.merge({content_type: :json}) if req_data
      req_args << req_opts
      RestClient.send method, *req_args do |response, request, result|
        res_data = JSON.parse response.to_s
        case response.code
        when 200
          yield res_data
        when 403
          raise res_data['error']
        else
          raise "Server returned an '#{response.code}' status code"
        end
      end
    end

    def send_file(path, file, &block)
      req_args = ["#{@url}#{path}"]
      req_args << {file: file}
      RestClient.post *req_args do |response, request, result|
        res_data = JSON.parse response.to_s
        case response.code
        when 200
          yield res_data
        when 403
          raise res_data['error']
        else
          raise "Server returned an '#{response.code}' status code"
        end
      end
    end
  end
end
