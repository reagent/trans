# frozen_string_literal: true

module Trans
  class Transcoder
    def initialize(config, source_path:, destination_path:)
      @config = config
      @source_file = source_path.join(@config.source_path)

      @destination_file = DestinationFile.new(
        @config.source.movie,
        path: destination_path
      )
    end

    def transcode
      @destination_file.dir.mkdir unless @destination_file.dir.exist?

      system(
        transcoder_path.to_s,
        '--crop', @config.crop,
        '--burn-subtitle', 'scan',
        '--add-subtitle', 'eng',
        '--main-audio', @config.audio_track,
        '--output', @destination_file.to_s,
        @source_file.to_s
      )
    end

    private

    def transcoder_path
      Pathname.new(__dir__).join('..', '..', 'bin', 'transcode-video')
    end
  end
end
