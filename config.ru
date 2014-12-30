# This file is used by Rack-based servers to start the application.
#
# Configure the app using environment variables
# (ex: 'STATICD_DOMAIN' to configure the 'domain' setting
require "staticd"

# Load configuration from environment variables.
Staticd::Config.load_env
Staticd::Config.load_file(ENV["STATICD_CONFIG"]) if ENV["STATICD_CONFIG"]

# Initialize and start the Staticd app.
app = Staticd::App.new(Staticd::Config)
app.run
