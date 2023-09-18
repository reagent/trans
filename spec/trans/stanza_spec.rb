RSpec.describe Trans::Stanza do
  describe '#to_h' do
    it 'returns a hash representation of a source configuration' do
      movie = Trans::Movie.new('The Goonies', '1985')
      source = Trans::Source.new(movie, 'file.mkv')

      subject = described_class.new(source)

      expect(subject.to_h).to eq(
        {
          'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
          'source_file' => 'file.mkv',
          'transcoding_options' => {
            'crop' => 'auto',
            'audio_track' => '1',
            'subtitle_track' => 'scan'
          }
        }
      )
    end
  end
end
