# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','staticdctl','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'staticdctl'
  s.version = Staticdctl::VERSION
  s.author = 'Etienne Garnier'
  s.email = 'garnier.etienne@gmail.com'
  s.homepage = 'http://yuweb.fr'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI for the staticd API'
  s.files = [
    "bin/staticdctl",
    "lib/staticdctl.rb",
    "lib/staticdctl/rest_client.rb",
    "lib/staticdctl/version.rb",
    "lib/staticd_utils/archive.rb",
    "lib/staticd_utils/file_size.rb",
    "lib/staticd_utils/archive_file.rb"
  ]
  s.require_paths << 'lib'
  # s.has_rdoc = true
  # s.extra_rdoc_files = ['README.rdoc','staticdctl.rdoc']
  # s.rdoc_options << '--title' << 'staticdctl' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'staticdctl'
  s.add_development_dependency('rake')
  # s.add_development_dependency('rdoc')
  s.add_runtime_dependency('gli','2.12.2')
  s.add_runtime_dependency('rest_client')
end
