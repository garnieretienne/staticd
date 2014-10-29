module Staticd
  class Site
    include Staticd::Model::Serializer
    attr_accessor :name, :releases, :domain_names
  end
end
