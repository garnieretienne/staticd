module Staticd
  module Models

    # Dynamic Staticd configuration.
    #
    # Manage all configuration parameters for Staticd aimed to change during
    # the application runtime.
    class StaticdConfig
      include DataMapper::Resource

      property :name, String, key: true, unique: true
      property :value, String

      # Set a value for a parameter.
      #
      # If the parameter exist, its value is updated otherwise the parameter is
      # created with the privided value.
      #
      # Example:
      #   Staticd::Models::StaticdConfig.set_value(:foo, "bar")
      def self.set_value(name, value)
        name = name.to_s
        value = value.to_s
        if (param = get(name))
          param.update(value: value)
        else
          create(name: name, value: value)
        end
        value
      end

      # Get a value for a parameter.
      #
      # Return nil if no parameter with this name exist.
      #
      # Example:
      #   Staticd::Models::StaticdConfig.get_value(:foo)
      def self.get_value(name)
        name = name.to_s
        (param = get(name)) ? param.value : nil
      end

      # Get the parameter boolean value associed with its value.
      #
      # Convert boolean string into boolean value.
      #
      # Example:
      #   if Staticd::Models::StaticdConfig.ask_value?(:enable_god_mod)
      #     puts "God mod is enabled!"
      #   else
      #     puts "God mod is disabled!"
      #   end
      def self.ask_value?(name)
        boolean_string = get_value(name)
        case boolean_string
        when "true" then true
        when "false" then false
        else
          raise "Cannot convert a string into a boolean value"
        end
      end

      def to_s
        "#{name}: #{value}"
      end
    end
  end
end
