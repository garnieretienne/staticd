require "data_mapper"

module Staticd

  # Load models
  require "staticd/model/serializer"
  require "staticd/model/site"
  require "staticd/model/release"
  require "staticd/model/domain_name"

  case ENV["RACK_ENV"]
  when "test"
    DataMapper.setup(:default, "sqlite::memory:")
  when "production"
    puts "Running database in production mode"
    unless ENV["DATABASE_URL"]
      raise "The DATABASE_URL environment variable must be set"
    end
    DataMapper.setup(:default, ENV["DATABASE_URL"])
  else
    puts "Running database in development mode"
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, "sqlite:///tmp/staticd-development.db")
  end

  DataMapper.finalize
  if ENV["RACK_ENV"] == "test"
    DataMapper.auto_migrate!
  else
    DataMapper.auto_upgrade!
  end
end
