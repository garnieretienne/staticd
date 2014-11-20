module Staticd
  module Models
    module Serializer

      # Return a hash of public attributes
      def to_h(context=nil)
        case context
        when :full
          data = attributes
          links = self.model.relationships.map{|association| association.name}
          links.each do |link|
            linked_data = self.send(link)
            linked_data_value = if linked_data.respond_to?(:map)
              linked_data.map{|element| element.attributes}
            else
              linked_data.attributes
            end
            data.merge!(link => linked_data_value)
          end
          data
        else
          attributes
        end
      end
    end
  end
end
