require "staticdctl/rest_client"

module Staticdctl

  # Class to interact with the Staticd API.
  #
  # Example:
  #   staticd_client = Staticdctl::StaticdClient.new(
  #     url: "http://staticd.domain.tld/api",
  #     access_id: ENV["STATICD_ACCESS_ID"],
  #     secret_key: ENV["STATICD_SECRET_KEY"]
  #   )
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

    def sites
      @staticd_api.call(:get, "/sites") do |data|
        yield build_response(data)
      end
    end

    def create_site(site_params)
      @staticd_api.call(:post, "/sites", site_params) do |data|
        yield build_response(data)
      end
    end

    def destroy_site(site_name)
      @staticd_api.call(:delete, "/sites/#{site_name}") do
        yield
      end
    end

    def domains(site_name)
      @staticd_api.call(:get, "/sites/#{site_name}/domain_names") do |data|
        yield build_response(data)
      end
    end

    def attach_domain(site_name, domain_params)
      @staticd_api.call(
        :post,
        "/sites/#{site_name}/domain_names",
        domain_params
      ) do |data|
        yield build_response(data)
      end
    end

    def detach_domain(site_name, domain_name)
      @staticd_api.call(
        :delete,
        "/sites/#{site_name}/domain_names/#{domain_name}"
      ) do
        yield
      end
    end

    def releases(site_name)
      @staticd_api.call :get, "/sites/#{site_name}/releases" do |data|
        yield build_response(data)
      end
    end

    def create_release(site_name, archive_file, sitemap_file)
      @staticd_api.send_files(
        "/sites/#{site_name}/releases",
        {file: archive_file, sitemap: sitemap_file}
      ) do |data|
        yield build_response(data)
      end
    end

    # Parse a sitemap of resources digest and return of sitemap purged of
    # already know resources.
    #
    # Submit a list of resources sha1 digests with HTTP path (in the sitemap
    # format) and get a list purged of already known resources (resources
    # already stored in database).
    def cached_resources(digests)
      @staticd_api.call(:post, "/resources/get_cached", digests) do |data|
        yield build_response(data)
      end
    end

    private

    def build_response(data)
      data.kind_of?(Array) ? build_collection(data) : build_object(data)
    end

    def build_collection(data)
      data.map { |element| build_object(element) }
    end

    def build_object(data)
      struct = OpenStruct.new
      data.each do |key, value|
        struct[key] =
          case
          when value.kind_of?(Array) then build_collection(value)
          when value.kind_of?(Hash) then build_object(value)
          else value
          end
      end
      struct
    end
  end
end
