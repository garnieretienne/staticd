require "rake/testtask"
require "staticd"

desc "Run the tests"
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.pattern = "test/**/*_test.rb"
    t.verbose = true
  end
end

desc "Run an IRB console"
task :console do
  require "irb"
  require "staticd"
  init_app
  ARGV.clear
  IRB.start
end

desc "Disable the setup page"
task :disable_setup_page do
  init_app
  print "Disabling setup page... "
  Staticd::Models::StaticdConfig.set_value(:disable_setup_page, true)
  puts "done."
end

desc "Enable the setup page"
task :enable_setup_page do
  init_app
  print "Enabling setup page... "
  Staticd::Models::StaticdConfig.set_value(:disable_setup_page, false)
  puts "done."
end

def init_app
  # Load configuration from environment variables.
  Staticd::Config.load_env
  Staticd::Config.load_file(ENV["STATICD_CONFIG"]) if ENV["STATICD_CONFIG"]
  Staticd::Config << {environment: "rake"}

  # Initialize and start the Staticd app.
  Staticd::App.new(Staticd::Config)
end
