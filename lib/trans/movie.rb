# frozen_string_literal: true

module Trans
  class Movie
    attr_reader :title, :year, :file

    def initialize(title, year, file)
      @title = title
      @year = year
      @file = file
    end

    def ==(other)
      other.instance_of?(self.class) &&
        other.title == title &&
        other.year == year
    end
  end
end
