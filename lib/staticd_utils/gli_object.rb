require 'gli'

# Move the GLI::App module into its own class.
#
# It's usefull to build a GLI::App like object.
#
# Example:
#   gli = GLIObject.new
#   gli.program_desc("My Ultimate CLI")
#   gli.version("1.0")
#   gli.run(*args)
class GLIObject
  include GLI::App
end
