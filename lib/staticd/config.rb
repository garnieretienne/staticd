require 'yaml'
require 'erb'

module Staticd
  class Config

    def self.parse(config_file, environment)
      @environment = environment.to_s
      if File.exist? config_file
        File.open config_file, 'r' do |file|
          content = ERB.new(file.read).result
          config = YAML.load(content)
          if config && config.has_key?(@environment)
            @config = config[@environment]
          end
        end
      end
      @config ||= []
    end
  end
end
