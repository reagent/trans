RSpec.describe Trans::ConfigurationFile do
  include Spec::FilesystemHelper

  describe '.load' do
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

  describe '.init' do
    context 'when the file does not exist' do
      it 'creates an empty configuration file' do
        with_temp_dir do |dir|
          described_class.init(dir, 'missing.yml')

          aggregate_failures do
            file = dir.join('missing.yml')

            expect(file).to exist
            expect(YAML.load_file(file)).to eq({ 'pending' => [],
                                                 'configured' => [] })
          end
        end
      end

      it 'returns the configuration' do
        with_temp_dir do |dir|
          configuration = described_class.init(dir, 'missing.yml')

          expect(configuration).to be_instance_of(Trans::ConfigurationFile)
          expect(configuration.to_h).to eq({ 'pending' => [],
                                             'configured' => [] })
        end
      end
    end

    context 'when the file exists' do
      it 'returns the file' do
        with_temp_dir do |dir|
          contents = {
            'configured' => [],
            'pending' => [
              {
                'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
                'source_file' => 'The Goonies (1985)/movie.mkv',
                'transcoding_options' => { 'audio_track' => '1',
                                           'crop' => 'auto', 'subtitle_track' => 'scan' }
              }
            ]
          }

          file = dir.join('config.yml')
          file.write(YAML.dump(contents))

          configuration = described_class.init(dir, 'config.yml')
          expect(configuration.to_h).to eq(contents)
        end
      end
    end
  end

  describe '#sources' do
    it 'is empty when there are no sources configured' do
      subject = described_class.new({})
      expect(subject.sources).to be_empty
    end

    it 'returns pending sources' do
      subject = described_class.new(
        {
          'pending' => [
            { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
              'source_file' => 'The Goonies (1985)/movie.mkv' }
          ]
        }
      )

      sources = subject.sources

      aggregate_failures do
        expect(sources.length).to eq(1)
        expect(sources.first.movie.title).to eq('The Goonies')
        expect(sources.first.movie.year).to eq('1985')
        expect(sources.first.relative_path).to eq('The Goonies (1985)/movie.mkv')
      end
    end

    it 'returns all sources' do
      subject = described_class.new(
        {
          'configured' => [
            { 'movie' => { 'title' => 'The Goonies', 'year' => '1985' },
              'source_file' => 'The Goonies (1985)/movie.mkv' }
          ],
          'pending' => [
            { 'movie' => { 'title' => 'Taxi Driver', 'year' => '1976' },
              'source_file' => 'Taxi Driver (1976)/movie.mkv' }
          ]
        }
      )

      sources = subject.sources

      aggregate_failures do
        expect(sources.length).to eq(2)

        expect(sources.first.movie.title).to eq('The Goonies')
        expect(sources.last.movie.title).to eq('Taxi Driver')
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
            'pending' => [],
            'configured' => []
          }
        )
      end
    end

    it 'writes a file with the provided sources' do
      with_temp_dir do |dir|
        subject = described_class.new({})

        goonies = Trans::Movie.new('The Goonies', '1985')
        taxi_driver = Trans::Movie.new('Taxi Driver', '1976')

        goonies_source = Trans::Source.new(goonies,
                                           'The Goonies (1985)/movie.mkv')
        taxi_driver_source = Trans::Source.new(taxi_driver,
                                               'Taxi Driver (1976)/movie.mkv')

        subject.configured.push(goonies_source)
        subject.pending.push(taxi_driver_source)

        subject.write_to(dir, 'config.yml')

        expect(YAML.load_file(dir.join('config.yml'))).to \
          eq({
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
        )
      end
    end
  end
end
