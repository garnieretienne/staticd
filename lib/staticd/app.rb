require "rack"

module Staticd

  # Staticd App.
  #
  # This class manage the app initialization and runtime.
  #
  # Example:
  #   app = Staticd::App.new(config)
  #   app.run
  class App

    # Initialize the Staticd app.
    #
    # General configuration:
    # * environment: the app environment (test, development or production)
    # * domain: base to generate per app sub-domain
    # * database: database url to store resources metadata
    # * datastore: datastore url to store resources
    # * port: port to listen to
    #
    # API service configuration:
    # * api: enable the API service
    # * access_id: HMAC authentication access ID for the API service
    # * secret_key: HMAC authentication secret key for the API service
    #
    # HTTP service configuration:
    # * http: enable the HTTP service
    # * http_cache: folder where resources are cached
    def initialize(config)
      @config = config
      require_settings(:environment, :domain, :database, :datastore)

      env = @config[:environment]
      puts "Starting Staticd in #{env} environment." unless env == "test"
      display_current_config if env == "development"

      init_database
      init_datastore
    end

    # Start the application.
    def run
      require_settings(:host, :port)
      require_settings(:http_cache) if @config[:http]
      require_settings(:access_id, :secret_key) if @config[:api]

      routes = {}
      routes["/"] = build_http_service if @config[:http]
      routes["/api"] = build_api_service if @config[:api]
      router = Rack::URLMap.new(routes)

      Rack::Server.start(
        Host: @config[:host],
        Port: @config[:port],
        app: router,
        environment: @config[:environment]
      )
    end

    private

    def require_settings(*settings)
      settings.each do |setting|
        unless @config.key?(setting) && !@config[setting].nil?
          raise "Missing '#{setting}' setting"
        end
      end
    end

    def display_current_config
      puts "Configuration:"
      puts "* Database: #{@config[:database]}"
      puts "* Datastore: #{@config[:datastore]}"

      if Staticd::Config[:api]
        puts "* Host: #{@config[:host]}"
        puts "* Port: #{@config[:port]}"
        puts "* Domain: #{@config[:domain]}"
        puts "* Access ID: #{@config[:access_id]}"
        puts "* Secret Key: #{@config[:secret_key]}"
      end

      if Staticd::Config[:http]
        puts "* HTTP cache: #{@config[:http_cache]}"
      end
    end

    def init_database
      Staticd::Database.setup(@config[:environment], @config[:database])
    end

    def init_datastore
      Staticd::Datastore.setup(@config[:datastore])
    end

    def build_api_service
      api_service = Staticd::API.new(
        domain: @config[:domain],
        port: @config[:port]
      )

      # Do not require HMAC authentication in test environment.
      return api_service unless @config[:environment] == "test"

      # Bind the API service with the HMAC middleware.
      raise "No access ID provided" unless @config[:access_id]
      raise "No secret_key provided" unless @config[:secret_key]
      Rack::Auth::HMAC.new(
        api_service, except: Staticd::API::PUBLIC_URI
      ) do |access_id|
        @config[:secret_key] if access_id == @config[:access_id].to_s
      end
    end

    def build_http_service
      http_service = Staticd::HTTPServer.new(@config[:http_cache])
      Staticd::HTTPCache.new(@config[:http_cache], http_service)
    end
  end
end
