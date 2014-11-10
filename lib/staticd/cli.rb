require 'staticd_utils/gli_object'
require 'rack'
require 'staticd/version'
require 'staticd/config'
require "staticd/database"

module Staticd
  class CLI

    def initialize
      @gli = GLIObject.new
      @gli.program_desc 'Staticd HTTP and API server'
      @gli.version Staticd::VERSION

      @gli.on_error{|exception| raise exception}

      build_commands
    end

    def run(*args)
      @gli.run *args
    end

    private

    def build_commands
      build_command_server
    end

    def build_command_server
      @gli.desc 'Start the staticd API and HTTP server'
      @gli.command :"server" do |c|

        c.switch [:api], desc: "Enable the API service" , default_value: false
        c.switch [:http], desc: "Enable the HTTP service", default_value: true
        c.flag [:p, :port], desc: "Port to listen to", default_value: 8080

        c.action do |global_options,options,args|

          ENV["STATICD_API_ENABLED"] = "true" if options[:api]
          ENV["STATICD_HTTP_ENABLED"] = "true" if options[:http]

          staticd_environment = if ENV["RACK_ENV"] == "production"
            :deployment
          else
            :development
          end

          config_file = "#{File.dirname(__FILE__)}/../../etc/staticd.yml.erb"
          config = Staticd::Config.parse config_file, staticd_environment
          config.to_env!

          Rack::Server.start(
            config: "#{File.dirname(__FILE__)}/../../config.ru",
            server: "puma",
            Port: options[:port],
            environment: staticd_environment
          )
        end
      end
    end
  end
end
