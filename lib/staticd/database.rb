require "data_mapper"

# Load models
require "staticd/model/serializer"
require "staticd/model/site"
require "staticd/model/release"
require "staticd/model/domain_name"
require "staticd/model/resource"
require "staticd/model/release_map"

module Staticd

  module Database

    def init_database(environment, database_url)
      environment = environment.to_sym
      puts "Running database in #{environment} mode" unless environment == :test

      if environment == :development
        level = :debug
        puts "Database #{level} info are logged to STDOUT during development"
        DataMapper::Logger.new($stdout, level)
      end

      DataMapper.setup(:default, database_url)
      DataMapper.finalize

      if environment == :test
        DataMapper.auto_migrate!
      else
        DataMapper.auto_upgrade!
      end
    end
  end
end
