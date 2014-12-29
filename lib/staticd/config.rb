require "singleton"

module Staticd

  # Manage Staticd Configuration.
  #
  # Can load configuration from a hash, from environment variables with the
  # STATICD_ prefix or from a config file in yaml format.
  #
  # Once loaded,configuration is available from anywhere in the app using
  # Staticd::Config[:setting].
  class Config
    include Singleton

    # Load configuration from environment variables.
    #
    # Example:
    #   ENV["STATICD_FOO"] = "bar"
    #   Staticd::Config.load_env
    #   Staticd::Config[:foo]
    #   # => "bar"
    def self.load_env
      settings = {}
      env = ENV.select { |name, value| name =~ /^STATICD_/ }
      env.each do |name, value|
        setting = name[/^STATICD_(.*)/, 1].downcase.to_sym
        settings[setting] = value
      end
      instance << settings
    end

    # Load configuration from a YAML file.
    #
    # The configuration file can contain ERB code.
    #
    # Example (config file)
    #   ---
    #   foo: bar
    #
    # Example:
    #   Staticd::Config.load_file("/etc/staticd/staticd.yml")
    #   Staticd::Config[:foo]
    #   # => "bar"
    def self.load_file(config_file)
      content = File.read(config_file)
      erb = ERB.new(content)
      settings = YAML.load(erb.result)
      instance << settings
    end

    # Push settings into Staticd global configuration.
    #
    # String setting keys are converted to symbols.
    #
    # Example:
    #   Staticd::Config << {"foo" => bar}
    #   Staticd::Config[:foo]
    #   # => "bar"
    def self.<<(settings)
      instance << settings
    end

    # Get a setting value from the Staticd global configuration.
    def self.[](setting)
      instance[setting]
    end

    def self.key?(setting_name)
      instance.key?(setting_name)
    end

    def self.to_s
      instance.to_s
    end

    def initialize
      @settings = {}
    end

    def <<(settings)
      settings = hash_symbolize_keys(settings)
      mutex.synchronize { @settings.merge!(settings) }
    end

    def [](setting)
      mutex.synchronize { @settings.key?(setting) ? @settings[setting] : nil }
    end

    def key?(setting_name)
      mutex.synchronize { @settings.key?(setting_name) }
    end

    def to_s
      mutex.synchronize { @settings.to_s }
    end

    private

    def hash_symbolize_keys(hash)
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
      hash
    end

    def mutex
      @mutex ||= Mutex.new
    end
  end
end
