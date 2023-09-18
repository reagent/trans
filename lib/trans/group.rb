# frozen_string_literal: true

module Trans
  class Group
    extend Forwardable
    include Enumerable

    def_delegators :@outputs, :each, :length

    def initialize(label, deserialized)
      @label = label
      @outputs = deserialized.map { |attrs| Stanza.build(attrs) }
    end

    def sources
      @outputs.map(&:source)
    end

    def push(source)
      @outputs.push(Stanza.new(source))
    end

    def to_h
      @outputs.map(&:to_h)
    end
  end
end
