require "sinatra/base"
require "staticd/database"
require "staticd/store"
require "staticd/json_response"
require "staticd/json_request"
require "staticd/domain_generator"
require "rack/auth/hmac"
require "staticd_utils/archive"

module Staticd
  class API < Sinatra::Base
    include Staticd::Model

    # Configure the app
    configure do
      set :app_file, __FILE__
      set :show_exceptions, false
    end

    # Require HMAC authentication
    use Rack::Auth::HMAC do |access_id|
      if access_id.to_s == ENV["STATICD_ACCESS_ID"]
        ENV["STATICD_SECRET_KEY"]
      end
    end

    # Create a new site
    #
    # @param name [String] the name of the new site
    # @return [Hash] the site attributes
    # @example Using curl
    #   curl --data '{"name": "my_app"}' http://localhost/api/sites
    # @example Output
    #   {"name":"my_app"}
    post "/sites" do
      request.body.rewind
      data = JSONRequest.parse request.body.read
      site = Site.new name: data["name"]
      site.domain_names << DomainName.new(
        name: DomainGenerator.new(
          site.name,
          ENV["STATICD_WILDCARD_DOMAIN"]
        )
      )
      if site.save
        JSONResponse.send :success, site.to_h(:full)
      else
        msg = site.errors.full_messages.first
        JSONResponse.send :error, "Cannot create the new site (#{msg})"
      end
    end

    # Get a list of all sites with releases and attached domain names
    #
    # @return [Array] a collection of sites
    # @example Using curl
    #   curl localhost/api/sites
    # @example Output
    #   [{
    #     "name":"my_app",
    #     "releases":[],
    #     "domain_names":[{"name":"my_app.com","site_name":"my_app"}]
    #   }]
    get "/sites" do
      sites = Site.all.map{|site| site.to_h(:full)}
      JSONResponse.send :success, sites
    end

    # Delete a site and all its associated resources (releases, domains, etc...)
    # If successfully deleted, it does not respond with any content.
    #
    # @param name [String] the name of the site (url)
    delete "/sites/:name" do
      site = Site.get params[:name]
      if site
        if site.destroy
          JSONResponse.send :success_no_content
        else
          JSONResponse.send :error, "Cannot remove the site '#{site.name}'"
        end
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:name]}) does not exist"
        )
      end
    end

    # Create a new site release
    #
    # @param site_name [String] the name of the site (url)
    # @param file [File] the gzipped tarball containing the site files
    # @return [Hash] the new release attributes
    # @example Using curl
    #   curl --form file=@archive.tar.gz localhost/api/sites/my_app/releases
    # @example Output
    #   {
    #     "id":1,
    #     "tag":"v1",
    #     "site_name":"my_app"
    #   }
    post "/sites/:site_name/releases" do
      JSONResponse.send :error, "No archive file sent" unless params[:file]
      site = Site.get params[:site_name]
      if site
        if params.has_key?("file") && params[:file].has_key?(:tempfile)
          tag = "v#{site.releases.count + 1}"
          release = Release.new site: site, tag: tag
          archive_path = params[:file][:tempfile].path
          Dir.mktmpdir do |tmp|
            archive = StaticdUtils::Archive.open_file archive_path
            archive.extract tmp
            storage = Store.new ENV["STATICD_DATASTORE"]
            Dir.chdir(tmp) do
              Dir.glob('**/*') do |file_path|
                next unless File.file? file_path

                resource_url = storage.exist?(file_path) ||
                    storage.put(file_path)

                resource = Resource.first(url: resource_url) ||
                    Resource.new(url: resource_url)

                release.release_maps.new(
                  resource: resource,
                  path: "/#{file_path}"
                )
              end
            end
          end
          if release.save
            JSONResponse.send :success, release.to_h
          else
            msg = release.errors.full_messages.first
            JSONResponse.send :error, "Cannot create the new release (#{msg})"
          end
        else
          JSONResponse.send :error, "No valid archive file submitted"
        end
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:site_name]}) does not exist"
        )
      end
    end

    # Get all releases of a site
    #
    # @param site_name [String] the name of the site (url)
    # @return [Array] the tag of each releases
    # @example Using curl
    #   curl localhost/api/sites/my_app/releases
    # @example Ouput
    #   [{
    #     "id": "1",
    #     "tag": "v1",
    #     "url": "/tmp/store/20ebde5306c481363297008c70bd45e2.tar.gz",
    #     "site_name": "my_app"
    #   }]
    get "/sites/:site_name/releases" do
      site = Site.get params[:site_name]
      if site
        tags = site.releases.map{|releases| releases.to_h}
        JSONResponse.send :success, tags
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:site_name]}) does not exist"
        )
      end
    end

    # Attach a new domain name to a site
    #
    # @param site_name [String] the name of the site (url)
    # @param name [String] the domain name to attach
    # @return [Hash] the domain name attributes
    # @example Using curl
    #   curl --data '{"name": "hello.io"}' \
    #     localhost/api/sites/my_app/domain_names
    # @example Output
    #   {"name":"hello.io","site_name":"my_app"}
    post "/sites/:site_name/domain_names" do
      site = Site.get params[:site_name]
      if site
        request.body.rewind
        data = JSONRequest.parse request.body.read
        domain_name = DomainName.new site: site, name: data["name"]
        if domain_name.save
          JSONResponse.send :success, domain_name.to_h
        else
          msg = domain_name.errors.full_messages.first
          JSONResponse.send :error, "Cannot create the new domain name (#{msg})"
        end
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:site_name]}) does not exist"
        )
      end
    end

    # Detach a domain name from a site
    # If successfully deleted, it does not respond with any content.
    #
    # @param site_name [String] the name of the site (url)
    # @param name [String] the domain name (url)
    delete "/sites/:site_name/domain_names/:name" do
      site = Site.get params[:site_name]
      if site
        domain = site.domain_names.get params[:name]
        if domain
          if domain.destroy
            JSONResponse.send :success_no_content
          else
            JSONResponse.send(
            :error,
            "Cannot detach the #{params[:name]} domain name from the " +
              "#{site.name} site"
          )
          end
        else
          JSONResponse.send(
            :error,
            "This domain name (#{params[:name]}) is not attached to the " +
              "#{site.name} site"
          )
        end
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:site_name]}) does not exist"
        )
      end
    end

    # Get all domain names attached to a site
    #
    # @param site_name [String] the name of the site (url)
    # @return [Array] a list of all domain names
    # @example Using curl
    #   curl localhost/api/sites/my_app/domain_names
    # @example Output
    #   [{"name": "hello.io"}]
    get "/sites/:site_name/domain_names" do
      site = Site.get params[:site_name]
      if site
        domains = site.domain_names.map{|domain| domain.to_h}
        JSONResponse.send :success, domains
      else
        JSONResponse.send(
          :error,
          "This site (#{params[:site_name]}) does not exist"
        )
      end
    end
  end
end
