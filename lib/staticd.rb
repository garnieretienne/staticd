Dir["#{File.dirname(__FILE__)}/staticd/**/*.rb"].each do |library|
  require library
end

module Staticd
  include Staticd::Models
end
