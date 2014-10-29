require "staticdctl/rest_client"

module Staticdctl
  class StaticdClient

    def initialize(url, hmac={})
      url = url
      access_id = hmac[:access_id] || ""
      secret_key = hmac[:secret_key] || ""
      @staticd_api = Staticdctl::RESTClient.new(
        url,
        access_id: access_id,
        secret_key: secret_key
      )
    end

    def sites(&block)
      @staticd_api.call :get, "/sites" do |data|
        yield build_response(data)
      end
    end

    def create_site(params, &block)
      @staticd_api.call :post, "/sites", params do |data|
        yield build_response(data)
      end
    end

    def domains(site, &block)
      @staticd_api.call :get, "/sites/#{site}/domain_names" do |data|
        yield build_response(data)
      end
    end

    def attach_domain(site, params, &block)
      @staticd_api.call :post, "/sites/#{site}/domain_names", params do |data|
        yield build_response(data)
      end
    end

    def releases(site, &block)
      @staticd_api.call :get, "/sites/#{site}/releases" do |data|
        yield build_response(data)
      end
    end

    def create_release(site, archive_file, &block)
      @staticd_api.send_file "/sites/#{site}/releases", archive_file do |data|
        yield build_response(data)
      end
    end

    private

    def build_response(data)
      if data.kind_of? Array
        build_collection(data)
      else
        build_object(data)
      end
    end

    def build_collection(data)
      data.map{|element| build_object(element)}
    end

    def build_object(data)
      struct = OpenStruct.new
      data.each do |key, value|
        if value.kind_of? Array
          struct[key] = build_collection(value)
        elsif value.kind_of? Hash
          struct[key] = build_object(value)
        else
          struct[key] = value
        end
      end
      struct
    end
  end
end
