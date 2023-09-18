# frozen_string_literal: true

module Trans
  class Stanza
    def self.build(attrs)
      movie = Trans::Movie.new(attrs.dig('movie', 'title'),
                               attrs.dig('movie', 'year'))
      new(Trans::Source.new(movie, attrs.fetch('source_file')))
    end

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def to_h
      {
        'source_file' => @source.relative_path,
        'movie' => {
          'title' => @source.movie.title,
          'year' => @source.movie.year
        },
        'transcoding_options' => {
          'crop' => 'auto',
          'audio_track' => '1',
          'subtitle_track' => 'scan'
        }
      }
    end
  end
end
