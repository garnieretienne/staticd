require "sinatra/base"
require "staticd/database"
require "staticd/store"
require "staticd/json_response"
require "staticd/json_request"
require "staticd/domain_generator"
require "rack/auth/hmac"
require "staticd_utils/archive"
require "staticd_utils/sitemap"
require "digest/sha1"

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

      [:file, :sitemap].each do |param|
        unless params.has_key?(param.to_s) && params[param].has_key?(:tempfile)
          return JSONResponse.send :error, "No valid #{param} file submitted"
        end
      end
      archive_path = params[:file][:tempfile].path
      sitemap_path = params[:sitemap][:tempfile].path

      # Get the current site
      site = Site.get params[:site_name]
      return JSONResponse.send :error,
        "This site (#{params[:site_name]}) does not exist" unless site

      # Create a new release
      release = Release.new site: site, tag: "v#{site.releases.count + 1}"

      # Open the sitemap file
      sitemap = StaticdUtils::Sitemap.open File.read(sitemap_path)

      # Open the archive file
      archive = StaticdUtils::Archive.open_file archive_path

      # Open the storage adapter
      storage = Store.new ENV["STATICD_DATASTORE"]

      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          archive.extract tmp

          # Store each new resources and build routes for known resources
          sitemap.each_resources do |sha1, path|

            # Store of retrieve each resources
            resource = if File.exist? sha1

              # Verify file integrity
              calc_sha1 = Digest::SHA1.hexdigest File.read(sha1)
              unless sha1 == calc_sha1
                return JSONResponse.send :error,
                  "The file #{path} digest recorded inside the sitemap file " +
                  "is not correct"
              end

              # Store the file
              resource_url = storage.put(sha1)

              # Create the resource
              Resource.new(sha1: sha1, url: resource_url)
            else

              # Get the resource from the database
              cached = Resource.get sha1
              unless cached
                return JSONResponse.send :error,
                  "A resource is missing (missing file and database record)"
              end
              cached
            end

            # Create the release route
            release.routes.new(
              resource: resource,
              path: path
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

    # Get all already known resources included in a sitemap
    #
    # @param raw [Hash] the sitemap hash
    # @return [Hash] the sitemap minus already known resources entry
    # @example Using curl
    #   curl --data '{"92136ff551f50188f46486ab80db269eda4dfd4e":"/hi.html"}' \
    #       localhost/api/resources/get_cached
    # @example Output (when resource is known)
    #   {}
    # @example Output (when resource is not known)
    #   {"92136ff551f50188f46486ab80db269eda4dfd4e":"/hi.html"}
    post "/resources/get_cached" do
      map = JSONRequest.parse request.body.read
      unknow_resources_map = map
      sitemap = StaticdUtils::Sitemap.new(map)
      known_resources = Resource.all sha1: sitemap.digests
      known_resources.each do |resource|
        unknow_resources_map.delete resource.sha1
      end
      JSONResponse.send :success, unknow_resources_map
    end
  end
end
