require "data_mapper"

module Staticd
  module Models

    # Base class for Staticd Datamapper models
    class Base

      # Return a hash of public attributes of the model
      #
      # Take a context as argument (default to :normal).
      # Available contexts are:
      # * normal: extract every public attributes of the model into a hash.
      # * full: extract every public attributes of the model and every public
      #   attributes of its associed models into a hash.
      def to_h(context=nil)
        case context
        when :full
          data = attributes
          links = model.relationships.map{ |association| association.name }
          links.each do |link|
            linked_data = send(link)
            linked_data_value =
              if linked_data.respond_to?(:map)
                linked_data.map{ |element| element.attributes }
              else
                linked_data.attributes
              end
            data.merge!({link => linked_data_value})
          end
          data
        else
          attributes
        end
      end
    end
  end
end
