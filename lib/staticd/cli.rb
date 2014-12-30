require "staticd_utils/gli_object"
require "staticd"

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
      @gli.desc("Start the staticd API and HTTP services")
      @gli.command(:server) do |c|
        c.switch([:api], desc: "enable the API service", default_value: true)
        c.switch([:http], desc: "enable the HTTP service", default_value: true)
        c.flag(
          [:environment],
          desc: "application environment",
          default_value: :development
        )
        c.flag(
          [:domain],
          desc: "domain to use to generate site sub-domain urls"
        )
        c.flag([:access_id], desc: "HMAC auth access id for the API service")
        c.flag([:secret_key], desc: "HMAC auth secret key for the API service")
        c.flag([:database], desc: "URL for the database")
        c.flag([:datastore], desc: "URL for the datastore")
        c.flag(
          [:http_cache],
          desc: "directory path where HTTP resources are cached",
          default_value: "/var/cache/staticd"
        )
        c.flag([:host], desc: "address to listen to", default_value: "0.0.0.0")
        c.flag([:port], desc: "port to listen to", default_value: 80)
        c.flag([:config], desc: "load a config file")
        c.action do |global_options, options,args|

          # Load configuration from command line options, environment variables
          # options and config file.
          Staticd::Config << options
          Staticd::Config.load_env
          Staticd::Config.load_file(options[:config]) if options[:config]

          # Initialize and start the Staticd app.
          app = Staticd::App.new(Staticd::Config)
          app.run
        end
      end
    end
  end
end
