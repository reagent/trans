# frozen_string_literal: true

module Trans
  class ConfigurationFile
    class Sources
      attr_reader :pending, :configured

      def initialize(attributes)
        @pending = Group.new(
          'pending',
          attributes.fetch('pending', [])
        )

        @configured = Group.new(
          'configured',
          attributes.fetch('configured', [])
        )
      end

      def all
        [@pending, @configured].flat_map(&:sources)
      end

      def to_h
        {
          'configured' => @configured.to_h,
          'pending' => @pending.to_h
        }
      end
    end
  end
end
