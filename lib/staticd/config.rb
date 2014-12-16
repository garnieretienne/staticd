require "yaml"
require "erb"

module Staticd

  # Manage Staticd configuration.
  #
  # Staticd code use environment variables to look for configuration.
  # This class can read a hash of configuration settings and export them
  # into environment variables used by the Staticd code.
  #
  # Available configuration settings are:
  # * wildcard_domain: the base wildcard domain name used to generate
  #   sub-domain name for each sites
  # * http_cache: the local directory path where the HTTP server will cache
  #   each resources it serve
  # * access_id: the access ID key used by the staticdctl client to
  #   authenticate against the API server (HMAC)
  # * secret_key: the secret access key used by the staticdctl client to
  #   authenticate against the API server (HMAC)
  # * database: the database url (ex: postgres://user:password@server/database)
  # * datastore: the datastore url (ex: s3://access:secret@host/bucket)
  #
  # Example:
  #   config = Staticd::Config.new(wildcard_domain: "my_domain.tld")
  #   config.to_env!
  #   puts ENV["STATICD_WILDCARD_DOMAIN"]
  #   # => "my_domain.tld"
  class Config
    SETTINGS =
      %i(wildcard_domain access_id secret_key database datastore http_cache)

    # Read Staticd configuration from a config file.
    #
    # The config file must be a YAML file and have the following structure:
    #   environment:
    #     setting: value
    #     another_setting: another_value
    # Only the settings present under the selected environment will be loaded.
    # The config file can be an ERB template.
    #
    # Example config file:
    #   staging:
    #     user: admin
    #     secret: password
    #   production
    #     user: <%= ENV['USER'] %>
    #     secret: <%= ENV['SECRET'] %>
    def self.parse(config_file, environment)
      environment = environment.to_s

      content = File.read(config_file)
      erb = ERB.new(content)
      yaml = YAML.load(erb.result)

      config = yaml.key?(environment) ? yaml[environment] : {}
      new config
    end

    # Verify each environment variable settings are set.
    #
    # Raise exeption if one setting is not set.
    #
    # Example:
    #   Staticd::Config.verify(["STATICD_GOD_MODE"])
    def self.verify(*settings)
      settings.each do |setting|
        raise "#{setting} environment variable is not set" unless ENV[setting]
      end
    end

    def initialize(config)
      @config = config
    end

    def [](setting)
      @config[setting.to_s] if @config.key?(setting.to_s)
    end

    def to_env!
      SETTINGS.each do |setting|
        setting_name = "STATICD_#{setting.to_s.upcase}"
        ENV[setting_name] = send(setting).to_s if send(setting)
      end
    end

    SETTINGS.each do |setting|
      define_method(setting) { self[setting] }
    end
  end
end
