RSpec.describe Trans::ConfigurationFile do
  include Spec::FilesystemHelper

  describe '.create', focus: true do
    it 'creates a configuration file with the provided locations' do
      with_temp_dir do |dir|
        file = described_class.create(
          dir.join('config.yml'),
          source_path: dir.join('Sources'),
          destination_path: dir.join('Transcoded')
        )

        aggregate_failures do
          expect(file).to be_instance_of(Trans::ConfigurationFile)
          expect(YAML.load_file(dir.join('config.yml'))).to eq(
            {
              'locations' => {
                'source' => dir.join('Sources').to_s,
                'destination' => dir.join('Transcoded').to_s
              },
              'sources' => {
                'configured' => [],
                'pending' => []
              }
            }
          )
        end
      end
    end

    it 'raises an exception when the file already exists' do
      with_temp_dir do |dir|
        path = dir.join('config.yml').tap { |p| FileUtils.touch(p) }

        expect do
          described_class.create(
            path,
            source_path: 'Sources',
            destination_path: 'Destination'
          )
        end.to raise_error(Trans::ConfigurationFile::FileExistsError)
      end
    end
  end

  describe '.load', focus: true do
    it 'raises an exception when the file does not exist' do
      with_temp_dir do |dir|
        expect { described_class.load(dir, 'missing.yml') }.to \
          raise_error(Trans::ConfigurationFile::FileNotFoundError)
      end
    end

    it 'raises an exception when the file contains invalid YAML' do
      Tempfile.create do |file|
        File.open(file, 'w') { |f| f << "-\n-\nx" } # Invalid YML

        expect { described_class.load(file) }.to \
          raise_error(Trans::ConfigurationFile::ParseError)
      end
    end
  end

  describe '#sources', focus: true do
    it 'raises an exception when there are no locations provided' do
      expect { described_class.new({}) }.to \
        raise_error(Trans::ConfigurationFile::MissingConfigurationError)
    end

    it 'is empty when there are no sources configured' do
      subject = described_class.new(
        {
          'locations' => {
            'source' => 'Source', 'destination' => 'Destination'
          }
        }
      )

      expect(subject.sources).to be_empty
    end

    it 'returns pending sources' do
      subject = described_class.new(
        {
          'locations' => { 'source' => 's', 'destination' => 'd' },
          'sources' => {
            'pending' => [
              { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                'source_file' => 'The Goonies (1985)/movie.mkv' }
            ]
          }
        }
      )

      sources = subject.sources

      expect(sources.length).to eq(1)

      aggregate_failures do
        expect(sources.first.movie.title).to eq('The Goonies')
        expect(sources.first.movie.year).to eq('1985')
        expect(sources.first.relative_path).to eq('The Goonies (1985)/movie.mkv')
      end
    end

    it 'returns all sources' do
      subject = described_class.new(
        {
          'locations' => { 'source' => 's', 'destination' => 'd' },
          'sources' => {
            'configured' => [
              { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                'source_file' => 'The Goonies (1985)/movie.mkv' }
            ],
            'pending' => [
              { 'movie' => { 'title' => 'Taxi Driver', 'year' => '1976' },
                'source_file' => 'Taxi Driver (1976)/movie.mkv' }
            ]
          }
        }
      )

      sources = subject.sources

      expect(sources.length).to eq(2)

      aggregate_failures do
        expect(sources.first.movie.title).to eq('Taxi Driver')
        expect(sources.last.movie.title).to eq('The Goonies')
      end
    end
  end

  describe '#write_to' do
    it 'creates an empty configuration file' do
      with_temp_dir do |dir|
        subject = described_class.new({})
        subject.write_to(dir, 'config.yml')

        expect(YAML.load_file(dir.join('config.yml'))).to eq(
          {
            'locations' => { 'source' => '', 'destination' => '' },
            'sources' => { 'pending' => [], 'configured' => [] }
          }
        )
      end
    end

    it 'writes a file with the provided sources' do
      with_temp_dir do |dir|
        subject = described_class.new(
          { 'locations' => { source: 'Source', destination: 'Destination' } }
        )

        goonies = Trans::Movie.new('The Goonies', '1985')
        taxi_driver = Trans::Movie.new('Taxi Driver', '1976')

        goonies_source = Trans::Source.new(
          goonies,
          'The Goonies (1985)/movie.mkv'
        )

        taxi_driver_source = Trans::Source.new(
          taxi_driver,
          'Taxi Driver (1976)/movie.mkv'
        )

        subject.configured.push(goonies_source)
        subject.pending.push(taxi_driver_source)

        subject.write_to(dir, 'config.yml')

        expect(YAML.load_file(dir.join('config.yml'))).to \
          eq({
               'locations' => { 'source' => 'Source',
                                'destination' => 'Destination' },
               'sources' => {
                 'configured' => [
                   { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                     'source_file' => 'The Goonies (1985)/movie.mkv',
                     'transcoding_options' => { 'audio_track' => '1',
                                                'crop' => 'auto', 'subtitle_track' => 'scan' } }
                 ],
                 'pending' => [
                   { 'movie' => { 'title' => 'Taxi Driver', 'year' => '1976' },
                     'source_file' => 'Taxi Driver (1976)/movie.mkv',
                     'transcoding_options' => { 'audio_track' => '1',
                                                'crop' => 'auto', 'subtitle_track' => 'scan' } }
                 ]
               }
             })
      end
    end

    it 'adds a source to the existing configuration' do
      with_temp_dir do |dir|
        subject = described_class.new(
          {
            'configured' => [
              { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                'source_file' => 'The Goonies (1985)/movie.mkv',
                'transcoding_options' => { 'audio_track' => '1', 'crop' => 'auto',
                                           'subtitle_track' => 'scan' } }
            ]
          }
        )

        movie = Trans::Movie.new('Taxi Driver', '1976')
        source = Trans::Source.new(movie, 'Taxi Driver (1976)/movie.mkv')

        subject.configured.push(source)

        subject.write_to(dir, 'config.yml')

        expect(YAML.load_file(dir.join('config.yml'))).to eq(
          {
            'sources' => {
              'configured' => [
                { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                  'source_file' => 'The Goonies (1985)/movie.mkv',
                  'transcoding_options' => { 'audio_track' => '1',
                                             'crop' => 'auto', 'subtitle_track' => 'scan' } },
                { 'movie' => { 'title' => 'Taxi Driver', 'year' => '1976' },
                  'source_file' => 'Taxi Driver (1976)/movie.mkv',
                  'transcoding_options' => { 'audio_track' => '1',
                                             'crop' => 'auto', 'subtitle_track' => 'scan' } }
              ],
              'pending' => []
            }
          }
        )
      end
    end
  end
end
