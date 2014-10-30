# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','staticd','version.rb'])

require File.join([File.dirname(__FILE__),'lib', 'gemfile', 'lock'])
gemfile = Gemfile::Lock.new("#{File.dirname(__FILE__)}/Gemfile.lock")

spec = Gem::Specification.new do |s|
  s.name = 'staticd'
  s.version = Staticd::VERSION
  s.license = "MIT"
  s.author = 'Etienne Garnier'
  s.email = 'garnier.etienne@gmail.com'
  s.homepage = 'http://www.yuweb.fr'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Staticd API and HTTP server'
  s.description = 'Staticd is a Rack app serving static content and supporting virtual hosts'
  s.files = Dir["lib/staticd/**/*"] + Dir["lib/staticd_utils/**/*"] + [
    "bin/staticd",
    "config.ru"
  ]
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'staticd'
  %w(
    rack puma sinatra rack-test data_mapper dm-postgres-adapter gli api-auth
    foreman
  ).each do |name|
    s.add_runtime_dependency name, *gemfile.find_requirements(name)
  end
  %w(rake byebug yard).each do |name|
    s.add_development_dependency name, *gemfile.find_requirements(name)
  end
end
