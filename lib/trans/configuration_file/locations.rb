# frozen_string_literal: true

module Trans
  class ConfigurationFile
    class Locations
      attr_reader :source, :destination

      def initialize(attributes)
        @source = Pathname(attributes.fetch('source'))
        @destination = Pathname(attributes.fetch('destination'))
      end

      def to_h
        {
          'source' => @source.to_s,
          'destination' => @destination.to_s
        }
      end
    end
  end
end
