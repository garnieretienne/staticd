Dir["#{File.dirname(__FILE__)}/staticd/**/*.rb"].each do |model_library|
  require model_library
end

include Staticd::Models
