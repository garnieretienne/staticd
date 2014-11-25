require "rack"
require "staticd/version"
require "staticd/config"
require "staticd/database"
require "staticd_utils/gli_object"

module Staticd
  class CLI

    def initialize
      @gli = GLIObject.new
      @gli.program_desc("Staticd HTTP and API server")
      @gli.version(Staticd::VERSION)
      @gli.on_error { |exception| raise exception }
      build_commands
    end

    def run(*args)
      @gli.run(*args)
    end

    private

    def build_commands
      build_command_server
    end

    def build_command_server
      @gli.desc("Start the staticd API and HTTP server")
      @gli.command(:server) do |c|
        c.switch([:api], desc: "Enable the API service", default_value: false)
        c.switch([:http], desc: "Enable the HTTP service", default_value: true)
        c.flag([:p, :port], desc: "Port to listen to", default_value: 8080)

        c.action do |global_options, options,args|
          ENV["STATICD_API_ENABLED"] = options[:api] ? "true" : "false"
          ENV["STATICD_HTTP_ENABLED"] = options[:http] ? "true" : "false"

          staticd_environment = ENV["RACK_ENV"] || "development"
          rack_environment =
            if staticd_environment == "production"
              :deployment
            else
              :development
            end

          staticd_root = "#{File.dirname(__FILE__)}/../.."

          config_file = "#{staticd_root}/etc/staticd.yml.erb"
          config = Staticd::Config.parse(config_file, staticd_environment)
          config.to_env!

          Rack::Server.start(
            config: "#{staticd_root}/config.ru",
            server: "puma",
            environment: rack_environment,
            Port: options[:port]
          )
        end
      end
    end
  end
end
