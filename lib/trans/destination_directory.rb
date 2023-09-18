# frozen_string_literal: true

module Trans
  class DestinationDirectory
    def initialize(path)
      @path = path
      @scanner = Scanner.new(@path)
    end

    def completed
      [].tap do |completed|
        @scanner.with_entries { |_d, movie| completed << movie }
      end
    end
  end
end
