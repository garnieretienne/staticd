require "sinatra/base"
require "staticd/database"
require "staticd/datastore/local"

class JSONResponse
  def self.send(type, content)
    case type
    when :success then
      @status = 200
      @body = content
    when :error
      @status = 403
      @body = {error: content}
    else
      @status = 500
      @body = {error: "something went wrong"}
    end
    [@status, JSON.generate(@body)]
  end
end

class JSONRequest
  def self.parse(body)
    body.empty? ? {} : JSON.parse(body)
  end
end

class API < Sinatra::Base
  set :app_file, __FILE__

  # Create a new site
  post "/sites" do
    request.body.rewind
    data = JSONRequest.parse request.body.read
    site = Site.new name: data["name"]
    if site.save
      JSONResponse.send :success, site.attributes
    else
      msg = site.errors.full_messages.first
      JSONResponse.send :error, "cannot create the new site (#{msg})"
    end
  end

  # Get a list of sites
  get "/sites" do
    names = Site.all.map{|site| site.name}
    JSONResponse.send :success, names
  end

  # Create a new site release
  post "/sites/:name/releases" do
    site = Site.get params[:name]
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
      JSONResponse.send :error, "This site (#{site}) does not exist"
    end
  end

  # Get all releases of a site
  get "/sites/:name/releases" do
    site = Site.get params[:name]
    if site
      tags = site.releases.map{|releases| releases.tag}
      JSONResponse.send :success, tags
    else
      JSONResponse.send :error, "this site (#{site}) does not exist"
    end
  end

  # Add a new domain name
  post "/sites/:name/domain_names" do
    site = Site.get params[:name]
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
      JSONResponse.send :error, "this site (#{site}) does not exist"
    end
  end
end
