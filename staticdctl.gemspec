# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','staticdctl','version.rb'])

require File.join([File.dirname(__FILE__),'lib', 'gemfile', 'lock'])
gemfile = Gemfile::Lock.new("#{File.dirname(__FILE__)}/Gemfile.lock")

spec = Gem::Specification.new do |s|
  s.name = 'staticdctl'
  s.version = Staticdctl::VERSION
  s.license = "MIT"
  s.author = 'Etienne Garnier'
  s.email = 'garnier.etienne@gmail.com'
  s.homepage = 'http://yuweb.fr'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI for the staticd API'
  s.description = 'CLI client to control a staticd app on a remote host'
  s.files = [
    "bin/staticdctl",
    "lib/staticdctl.rb",
    "lib/staticdctl/rest_client.rb",
    "lib/staticdctl/version.rb",
    "lib/staticd_utils/archive.rb",
    "lib/staticd_utils/file_size.rb",
    "lib/staticd_utils/archive_file.rb"
  ]
  s.files = Dir["lib/staticdctl/**/*"] + Dir["lib/staticd_utils/**/*"] + [
    "lib/staticdctl.rb",
    "bin/staticdctl"
  ]
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'staticdctl'
  %w(gli rest_client).each do |name|
    s.add_runtime_dependency name, *gemfile.find_requirements(name)
  end
end
