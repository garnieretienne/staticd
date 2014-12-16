require "rake/testtask"

desc "Run the tests"
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.pattern = "test/**/*_test.rb"
    t.verbose = true
  end
end

desc "Disable the setup page"
task :disable_setup_page do
  require "staticd"
  include Staticd::Models

  init_database
  print "Disabling setup page... "
  StaticdConfig.set_value(:disable_setup_page, true)
  puts "done."
end

desc "Enable the setup page"
task :enable_setup_page do
  require "staticd"
  include Staticd::Models

  init_database
  print "Enabling setup page... "
  StaticdConfig.set_value(:disable_setup_page, false)
  puts "done."
end

def init_database
  Staticd::Config.verify("RACK_ENV", "STATICD_DATABASE")
  Staticd::Database.init_database(ENV["RACK_ENV"], ENV["STATICD_DATABASE"])
end
