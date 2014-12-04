require "sinatra/base"
require "rack/auth/hmac"
require "digest/sha1"
require "haml"
require "open-uri"

require "staticd/json_response"
require "staticd/json_request"
require "staticd/domain_generator"

require "staticd/database"
require "staticd/datastore"

require "staticd_utils/archive"
require "staticd_utils/sitemap"

require "byebug" if ENV["RACK_ENV"] == "development"

module Staticd
  class APIError < StandardError; end

  class API < Sinatra::Base
    include Staticd::Models

    PING_KEY = ENV["STATICD_WILDCARD_DOMAIN"]

    configure do
      set :app_file, __FILE__
      set :show_exceptions, false
      set :raise_errors, false
    end

    # Manage API errors.
    error do
      raise env['sinatra.error']
    end
    error APIError do
      JSONResponse.send(:error, env['sinatra.error'].message)
    end

    # Require HMAC authentication.
    NOT_AUTHENTICATED = %w(
      /welcome /ping /main.css /main.js /jquery-1.11.1.min.js
    )
    use(Rack::Auth::HMAC, except: NOT_AUTHENTICATED) do |access_id|
      ENV["STATICD_SECRET_KEY"] if access_id.to_s == ENV["STATICD_ACCESS_ID"]
    end

    before do
      load_json_body
    end

    # Getting the Welcome Page.
    #
    # Display a welcome page with instructions to finish setup and configure
    # the Staticd toolbelt.
    get "/welcome" do
      config_disable_welcome_page = StaticdConfig.get("disable_welcome_page")
      if config_disable_welcome_page && !config_disable_welcome_page.value
        haml :welcome, layout: :main
      else
        @domain_resolve = ping?(ENV["STATICD_WILDCARD_DOMAIN"])
        @wildcard_resolve = ping?("wildcard.#{ENV["STATICD_WILDCARD_DOMAIN"]}")
        haml :setup, layout: :main
      end
    end

    # Hide the Welcome Page.
    #
    # After initial setup, you want to hide the welcome page displaying
    # sensitive data.
    delete "/welcome" do
      StaticdConfig.create(name: "disable_welcome_page", value: true)
    end

    # Ping page.
    #
    # Used by the ping command to verify a specified domain resolve to this app.
    get "/ping" do
      PING_KEY
    end

    # Create a new site.
    #
    # Responds with the new site attributes.
    # Parameters:
    # * name: the name of the new site
    #
    # Example:
    #   $> curl --data '{"name": "my_app"}' http://localhost/api/sites
    #   {"name":"my_app"}
    post "/sites" do
      site = Site.new(name: @json["name"])
      domain_suffix = ".#{ENV["STATICD_WILDCARD_DOMAIN"]}"
      domain = DomainGenerator.new(suffix: domain_suffix) do |generated_domain|
        !DomainName.get(generated_domain)
      end
      site.domain_names << DomainName.new(name: domain)

      if site.save
        JSONResponse.send(:success, site.to_h(:full))
      else
        raise APIError, "Cannot create the new site (#{site.error})"
      end
    end

    # Get a list of all sites.
    #
    # Responds with a list of sites with all attributes, releases and domain
    # names.
    #
    # Example:
    #   $> curl localhost/api/sites
    #   [{
    #     "name":"my_app",
    #     "releases":[],
    #     "domain_names":[{"name":"my_app.com","site_name":"my_app"}]
    #   }]
    get "/sites" do
      sites = Site.map{ |site| site.to_h(:full) }
      JSONResponse.send(:success, sites)
    end

    # Delete a site and all its associated resources (releases, domains,
    # etc...).
    #
    # If the site is successfully deleted, it does not responds with any
    # content.
    # Parameters:
    # * site_name: the name of the site (url)
    #
    # Example:
    #   $> curl --request DELETE localhost/api/sites/my_app
    delete "/sites/:site_name" do
      if current_site.destroy
        JSONResponse.send(:success_no_content)
      else
        raise APIError, "Cannot remove the site '#{current_site}'"
      end
    end

    # Create a new site release.
    #
    # Responds with the new releases attributes.
    # Parameters:
    # * site_name: the name of the site (url)
    # * file: the archive containing the site resources
    # * sitemap: a sitemap file indexing the site resources
    #
    # Example:
    #   $> curl --form "file=@archive.tar.gz;sitemap=@sitemap.yml" \
    #      localhost/api/sites/my_app/releases
    #   {
    #     "id":1,
    #     "tag":"v1",
    #     "site_name":"my_app"
    #   }
    post "/sites/:site_name/releases" do
      archive_path = load_file_attachment(:file)
      sitemap_path = load_file_attachment(:sitemap)

      # Create a new release.
      release = Release.new(
        site: current_site,
        tag: "v#{current_site.releases.count + 1}"
      )

      # Open the archive and sitemap file.
      archive = StaticdUtils::Archive.open_file(archive_path)
      sitemap = StaticdUtils::Sitemap.open_file(sitemap_path)

      # Open the storage adapter.
      storage = Datastore.new(ENV["STATICD_DATASTORE"])

      archive.open do

        # Store each new resources and build routes for known resources.
        sitemap.each_resources do |sha1, path|

          # Store or retrieve each resources.
          resource =
            if File.exist?(sha1)

              # Verify file integrity.
              calc_sha1 = Digest::SHA1.hexdigest(File.read(sha1))
              unless sha1 == calc_sha1
                raise APIError, "The file #{path} digest recorded inside " +
                      "the sitemap file is not correct"
              end

              # Store the file.
              resource_url = storage.put(sha1)

              # Create the resource.
              Resource.new(sha1: sha1, url: resource_url)
            else

              # Get the resource from the database.
              cached = Resource.get(sha1)
              unless cached
                raise APIError, "A resource is missing (missing file and " +
                      "database record)"
              end
              cached
            end

          # Create the release route.
          release.routes.new(resource: resource, path: path)
        end
      end

      if release.save
        JSONResponse.send(:success, release.to_h(:full))
      else
        raise APIError, "Cannot create the new release (#{release.error})"
      end
    end

    # Get all releases of a site.
    #
    # Respond with a list of releases and their attributes.
    # Parameters:
    # * site_name: the name of the site (url)
    #
    # Example:
    #   $> curl localhost/api/sites/my_app/releases
    #   [{
    #     "id": "1",
    #     "tag": "v1",
    #     "url": "/tmp/store/20ebde5306c481363297008c70bd45e2.tar.gz",
    #     "site_name": "my_app"
    #   }]
    get "/sites/:site_name/releases" do
      releases = current_site.releases.map{ |release| release.to_h }
      JSONResponse.send(:success, releases)
    end

    # Attach a new domain name to a site.
    #
    # Respond with the domain list attributes.
    # Parameters:
    # * site_name: the name of the site (url)
    # * name: the domain name to attach
    #
    # Example:
    #   $> curl --data '{"name": "hello.io"}' \
    #      localhost/api/sites/my_app/domain_names
    #   {"name":"hello.io","site_name":"my_app"}
    post "/sites/:site_name/domain_names" do
      domain_name = DomainName.new(site: current_site, name: @json["name"])

      if domain_name.save
        JSONResponse.send(:success, domain_name.to_h)
      else
        raise APIError, "Cannot create the new domain name " +
              "(#{domain_name.error})"
      end
    end

    # Detach a domain name from a site.
    #
    # If successfully deleted, it does not respond with any content.
    # Parameters:
    # * site_name: the name of the site (url)
    # * domain_name: the domain name (url)
    #
    # Example:
    #   $> curl --request DELETE \
    #      localhost/api/sites/my_app/domain_names/domain.tld
    delete "/sites/:site_name/domain_names/:domain_name" do
      if current_domain.destroy
        JSONResponse.send(:success_no_content)
      else
        raise APIError, "Cannot detach the #{params[:domain_name]} domain " +
              "name from the #{site} site"
      end
    end

    # Get all domain names attched to a site.
    #
    # Respond with a list of all domain names and their attributes attached to
    # the site.
    # Parameters:
    # * site_name: the name of the site (url)
    #
    # Example:
    #   $> curl localhost/api/sites/my_app/domain_names
    #   [{"name": "hello.io"}]
    get "/sites/:site_name/domain_names" do
      domains = current_site.domain_names.map{ |domain| domain.to_h }
      JSONResponse.send(:success, domains)
    end

    # Get all already known resources included in a sitemap.
    #
    # Get a list of resources in a custom sitemap format (translated into json)
    # and respond with the list of new resources (not already cached by any
    # release) in the same format.
    #
    # Example:
    #   $> curl --data \
    #      '{ \
    #         "92136ff551f50188f46486ab80db269eda4dfd4e":"/hi.html", \
    #         "56897ff551f50188f46486ab80db269eda4dfd4e":"/ho.html" \
    #       }' localhost/api/resources/get_cached
    #   {"92136ff551f50188f46486ab80db269eda4dfd4e":"/hi.html"}
    post "/resources/get_cached" do
      unknow_resources_map = map = @json
      sitemap = StaticdUtils::Sitemap.new(map)
      known_resources = Resource.all(sha1: sitemap.digests)
      known_resources.each do |resource|
        unknow_resources_map.delete(resource.sha1)
      end
      JSONResponse.send(:success, unknow_resources_map)
    end

    private

    def ping?(domain)
      open("http://#{domain}/api/ping", read_timeout: 1) do |response|
        response.read == PING_KEY
      end
    rescue
      false
    end

    def load_json_body
      if request.content_type == "application/json"
        request.body.rewind
        @json = JSONRequest.parse(request.body.read)
      end
    end

    def load_file_attachment(field)
      unless params.has_key?(field.to_s) && params[field].has_key?(:tempfile)
        raise APIError, "No valid #{field} file submitted"
      end
      params[field][:tempfile].path
    end

    def current_site
      if (@current_site ||= Site.get(params[:site_name]))
        @current_site
      else
        raise APIError, "This site (#{params[:site_name]}) does not exist"
      end
    end

    def current_domain
      if (@domain ||= current_site.domain_names.get(params[:domain_name]))
        @domain
      else
        raise APIError, "This domain name (#{params[:domain_name]}) is not " +
              "attached to the #{current_site} site"
      end
    end
  end
end
