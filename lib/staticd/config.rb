require 'yaml'
require 'erb'

module Staticd
  class Config

    SETTINGS = [
      :wildcard_domain,
      :access_id,
      :secret_key,
      :database,
      :datastore,
      :http_cache
    ]

    def initialize(config)
      @config = config
    end

    def self.parse(config_file, environment)
      environment = environment.to_s
      config = {}
      if File.exist? config_file
        File.open config_file, 'r' do |file|
          content = ERB.new(file.read).result
          config = YAML.load(content)
          if config && config.has_key?(environment)
            config = config[environment]
          else
            config = {}
          end
        end
      end
      new config
    end

    def [](setting)
      @config.has_key?(setting.to_s) ? @config[setting.to_s] : nil
    end

    SETTINGS.each do |setting|
      define_method setting do
        self[setting]
      end
    end

    def to_env!
      SETTINGS.each do |setting|
        setting_name = "STATICD_" + setting.to_s.upcase
        ENV[setting_name] = self.send(setting).to_s if self.send(setting)
      end
    end
  end
end
