# frozen_string_literal: true

module Trans
  class DestinationFile
    def initialize(movie, path:)
      @movie = movie
      @path = path
    end

    def to_s
      full_path.to_s
    end

    def dir
      @path.join("#{@movie.title} (#{@movie.year})")
    end

    def filename
      "#{@movie.title.gsub(/\s+/, '_')}.mkv"
    end

    def full_path
      dir.join(filename)
    end
  end
end
