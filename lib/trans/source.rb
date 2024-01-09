# frozen_string_literal: true

module Trans
  class Source
    attr_reader :medium

    def initialize(medium)
      @medium = medium
    end

    def relative_path
      @medium.file.to_s
    end

    def <=>(other)
      [medium.title, medium.year] <=> [other.medium.title, other.medium.year]
    end

    def ==(other)
      other.instance_of?(self.class) &&
        medium == other.medium &&
        relative_path == other.relative_path
    end
  end
end
