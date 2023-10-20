# frozen_string_literal: true

module Trans
  class Source
    attr_reader :movie

    def initialize(movie, file)
      @movie = movie
      @file = file
    end

    def relative_path
      @file.to_s
    end

    def <=>(other)
      [movie.title, movie.year] <=> [other.movie.title, other.movie.year]
    end

    def ==(other)
      other.instance_of?(self.class) &&
        movie == other.movie &&
        relative_path == other.relative_path
    end
  end
end
