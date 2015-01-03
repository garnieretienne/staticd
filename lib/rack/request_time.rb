
# Rack middleware to log request time.
#
# Add the request time to the request environment using request.time key.
class Rack::RequestTime

  def initialize(app)
    @app = app
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    env["request.time"] = Time.now
    @app.call(env)
  end
end
