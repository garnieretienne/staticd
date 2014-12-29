Dir["#{File.dirname(__FILE__)}/staticdctl/**/*.rb"].each do |library|
  require library
end
