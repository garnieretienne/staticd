require "data_mapper"

DataMapper.setup(:default, 'sqlite::memory:')

# Load models
Dir.glob("#{File.dirname(File.dirname(__FILE__))}/../models/*.rb") {|file|
  require file
}

DataMapper.finalize
DataMapper.auto_migrate!
