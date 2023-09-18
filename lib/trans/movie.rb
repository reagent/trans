# frozen_string_literal: true

module Trans
  class Movie
    attr_reader :title, :year

    def initialize(title, year)
      @title = title
      @year = year
    end

    def ==(other)
      other.instance_of?(self.class) &&
        other.title == title &&
        other.year == year
    end
  end
end
