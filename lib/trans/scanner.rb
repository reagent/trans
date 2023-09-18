# frozen_string_literal: true

module Trans
  class Scanner
    DIRECTORY_NAME_PATTERN = /\A(?<title>.+)\s+\((?<year>\d{4})\)\Z/

    def initialize(path)
      @path = path
    end

    def with_entries(&)
      @path.entries.each do |dir|
        next unless (matches = dir.to_s.match(DIRECTORY_NAME_PATTERN))

        files = @path.join(dir).entries.select { |e| e.to_s.end_with?('.mkv') }
        next if files.empty?

        elements = matches.named_captures
        movie = Movie.new(elements['title'], elements['year'])

        yield dir, movie, files
      end
    end
  end
end
