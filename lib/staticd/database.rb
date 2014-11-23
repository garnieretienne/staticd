require "data_mapper"

# Load models
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each do |model_library|
  require model_library
end

module Staticd
  module Database

    # Initialize the database.
    #
    # It support the test, development and production environment.
    # Database logger is silent in test environment, verbose in development
    # environment, and only displaying errors in production.
    def init_database(environment, database_url)
      environment = environment.to_sym
      puts "Running database in #{environment} mode." unless environment == :test

      log_enabled, destination, level =
        case environment
        when :development
          [true, '$stdout', :debug]
        when :production
          [true, '$stderr', :error]
        else
          [false]
        end

      if log_enabled
        puts "Database #{level} info are logged to #{destination}."
        DataMapper::Logger.new(eval(destination), level)
      end

      DataMapper.setup(:default, database_url)
      DataMapper.finalize
      environment == :test ? DataMapper.auto_migrate! : DataMapper.auto_upgrade!
    end
  end
end
