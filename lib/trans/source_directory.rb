# frozen_string_literal: true

module Trans
  class SourceDirectory
    def initialize(path)
      @scanner = Scanner.new(path)
    end

    def sources
      [].tap do |sources|
        @scanner.with_media { |m| sources.push(Source.new(m)) }
      end
    end
  end
end
