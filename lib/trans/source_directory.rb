# frozen_string_literal: true

module Trans
  class SourceDirectory
    def initialize(path)
      @path = path
      @scanner = Scanner.new(@path)
    end

    def sources
      [].tap do |sources|
        @scanner.with_entries do |dir, movie, files|
          sources.push(*files.map { |f| Source.new(movie, dir.join(f)) })
        end
      end
    end
  end
end
