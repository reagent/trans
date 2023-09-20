# frozen_string_literal: true

module Trans
  class Stanza
    def self.build(attrs)
      movie = Trans::Movie.new(
        attrs.dig('movie', 'title'),
        attrs.dig('movie', 'year')
      )

      new(
        Trans::Source.new(movie, attrs.fetch('source_file')),
        attrs.fetch('transcoding_options', {})
      )
    end

    attr_reader :source

    def initialize(source, transcoding_options = {})
      @source = source
      @transcoding_options = transcoding_options
    end

    def source_path
      @source.relative_path
    end

    def crop
      @transcoding_options.fetch('crop', 'auto')
    end

    def audio_track
      @transcoding_options.fetch('audio_track', '1')
    end

    def subtitle_track
      @transcoding_options.fetch('subtitle_track', 'scan')
    end

    def to_h
      {
        'source_file' => source_path,
        'movie' => {
          'title' => @source.movie.title,
          'year' => @source.movie.year
        },
        'transcoding_options' => {
          'crop' => crop,
          'audio_track' => audio_track,
          'subtitle_track' => subtitle_track
        }
      }
    end
  end
end
