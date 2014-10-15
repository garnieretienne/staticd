require 'dm-validations'

class Site
  include DataMapper::Resource

  property :name, String, key: true, unique: true

  has n, :releases
  has n, :domain_names
end
