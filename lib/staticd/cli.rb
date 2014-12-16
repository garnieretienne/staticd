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
        staticd_root = "#{File.dirname(__FILE__)}/../.."
        default_config_file = "#{staticd_root}/etc/staticd.yml.erb"

        c.switch([:api], desc: "Enable the API service", default_value: false)
        c.switch([:http], desc: "Enable the HTTP service", default_value: true)
        c.flag([:p, :port], desc: "Port to listen to", default_value: 8080)
        c.flag(
          [:c, :config],
          desc: "Path to the config file to use",
          default_value: default_config_file
        )

        c.action do |global_options, options,args|
          ENV["STATICD_API_ENABLED"] = options[:api] ? "true" : "false"
          ENV["STATICD_HTTP_ENABLED"] = options[:http] ? "true" : "false"

          staticd_environment = ENV["RACK_ENV"] || "development"
          rack_environment =
            staticd_environment == "production" ? :deployment : :development

          puts "Using configuration file: #{options[:config]}."
          config = Staticd::Config.parse(options[:config], staticd_environment)
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
