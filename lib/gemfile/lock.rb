module Gemfile

  # This class analyze the content of a Gemfile.lock file.
  #
  # It can be used into gemspec files to retrieve current version of gem used by
  # bundler.
  #
  # Example:
  #   gemfile = Gemfile::Lock.new("#{File.dirname(__FILE__)}/Gemfile.lock")
  #   s.executables << 'exe_name'
  #     s.add_runtime_dependency gem_name, *gemfile.find_requirements(gem_name)
  #   end
  class Lock

    def initialize(path)
      @content = File.read(path) if File.exist?(path)
    end

    def find_requirements(gem_name)
      return [] unless @content

      @content.scan(/    #{gem_name} \((.*)\)/).first.first.split(", ")
    rescue
      []
    end
  end
end
