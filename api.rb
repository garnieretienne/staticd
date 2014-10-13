require "sinatra"
require "data_mapper"
require "staticd/datastore/local"

set :app_file, __FILE__

configure :test do
  DataMapper.setup(:default, 'sqlite::memory:')
end

# Load models
Dir.glob("#{settings.root}/models/*.rb") {|file|
  require file
}

DataMapper.finalize
DataMapper.auto_migrate!

# Create a new site
post "/sites" do
  request.body.rewind
  data = JSON.parse request.body.read
  site = Site.new name: data["name"]
  site.save
  [200, JSON.generate(site.attributes)]
end

# Get a list of sites
get "/sites" do
  names = Site.all.map{|site| site.name}
  [200, JSON.generate(names)]
end

# Create a new site release
post "/sites/:name/releases" do
  request.body.rewind
  data = JSON.parse request.body.read
  site = Site.get params[:name]
  tag = "v#{site.releases.count + 1}"
  url = Datastore::Local.put_base64 data["file"]
  release = Release.new site: site, tag: tag, url: url
  release.save
  [200, JSON.generate(release.attributes)]
end

# Get all releases of a site
get "/sites/:name/releases" do
  site = Site.get params[:name]
  ids = site.releases.map{|releases| releases.id}
  [200, JSON.generate(ids)]
end
