class Site
  include DataMapper::Resource

  property :name, String, key: true

  has n, :releases
end
