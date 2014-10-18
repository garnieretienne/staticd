require "sinatra/base"
require "staticd/database"
require "staticd/datastore/local"
require "staticd/json_response"
require "staticd/json_request"

module Staticd
  class API < Sinatra::Base
    include Model

    set :app_file, __FILE__

    # Create a new site
    #
    # @param name [String] the name of the new site
    # @return [Hash] the site attributes
    # @example Using curl
    #   curl --data '{"name": "my_app"}' http://localhost:4567/api/sites
    # @example Output
    #   {"name":"my_app"}
    post "/sites" do
      request.body.rewind
      data = JSONRequest.parse request.body.read
      site = Site.new name: data["name"]
      if site.save
        JSONResponse.send :success, site.attributes
      else
        msg = site.errors.full_messages.first
        JSONResponse.send :error, "Cannot create the new site (#{msg})"
      end
    end

    # Get a list of all sites
    #
    # @return [Array] the name of each sites
    # @example Using curl
    #   curl localhost:4567/api/sites
    # @example Output
    #   ["my_app","another_app"]
    get "/sites" do
      names = Site.all.map{|site| site.name}
      JSONResponse.send :success, names
    end

    # Create a new site release
    #
    # @param site_name [String] the name of the site (url)
    # @param file [Text] the base64 encoded gzipped tarball containing the site
    #   files
    # @return [Hash] the new release attributes
    # @example Using curl
    #   base64_encoded=$(base64 test/fixtures/files/mywebsite.fr.tar.gz)
    #   curl --data "{\"file\": \"$base64_encoded\"}" \
    #       localhost:4567/api/sites/my_app/releases
    # @example Output
    #   {
    #     "id":1,
    #     "tag":"v1",
    #     "url":"/tmp/store/d41d8cd98f00b204e9800998ecf8427e.tar.gz",
    #     "site_name":"my_app"
    #   }
    post "/sites/:site_name/releases" do
      site = Site.get params[:site_name]
      if site
        request.body.rewind
        data = JSONRequest.parse request.body.read
        tag = "v#{site.releases.count + 1}"
        url = data["file"] ? Datastore::Local.put_base64(data["file"]) : nil
        release = Release.new site: site, tag: tag, url: url
        if release.save
          JSONResponse.send :success, release.attributes
        else
          msg = release.errors.full_messages.first
          JSONResponse.send :error, "Cannot create the new release (#{msg})"
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
    #   curl localhost:4567/api/sites/my_app/releases
    # @example Ouput
    #   ["v1","v2"]
    get "/sites/:site_name/releases" do
      site = Site.get params[:site_name]
      if site
        tags = site.releases.map{|releases| releases.tag}
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
    #     localhost:4567/api/sites/my_app/domain_names
    # @example Output
    #   {"name":"hello.io","site_name":"my_app"}
    post "/sites/:site_name/domain_names" do
      site = Site.get params[:site_name]
      if site
        request.body.rewind
        data = JSONRequest.parse request.body.read
        domain_name = DomainName.new site: site, name: data["name"]
        if domain_name.save
          JSONResponse.send :success, domain_name.attributes
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

    # Get all domain names attached to a site
    #
    # @param site_name [String] the name of the site (url)
    # @return [Array] a list of all domain names
    # @example Using curl
    #   curl localhost:4567/api/sites/my_app/domain_names
    # @example Output
    #   ["hello.io"]
    get "/sites/:site_name/domain_names" do
      site = Site.get params[:site_name]
      if site
        domains = site.domain_names.map{|domain| domain.name}
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
