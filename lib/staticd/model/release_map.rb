module Staticd
  module Model
    class ReleaseMap
      include DataMapper::Resource

      property :id, Serial, unique: true
      property :path, String, required: true

      belongs_to :release
      belongs_to :resource
    end
  end
end
