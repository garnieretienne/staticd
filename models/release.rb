class Release
  include DataMapper::Resource

  property :id, Serial
  property :tag, String, required: true
  property :url, String, required: true

  belongs_to :site
end
