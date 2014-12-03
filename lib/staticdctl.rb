Dir["#{File.dirname(__FILE__)}/staticdctl/**/*.rb"].each do |model_library|
  require model_library
end
