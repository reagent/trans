RSpec.describe Trans::SourceDirectory do
  include Spec::FilesystemHelper

  describe '#sources' do
    it 'returns a list of matched sources' do
      with_temp_dir do |dir|
        non_matching_directory = dir.join('directory').tap(&:mkdir)
        matching_directory_without_files = dir.join('The Goonies (1985)').tap(&:mkdir)

        non_matching_directory_with_file = dir.join('directory with files').tap do |dir|
          dir.mkdir
          FileUtils.touch(dir.join('source.mkv'))
        end

        matching_directory_with_unknown_files = dir.join('A Fistful of Dollars (1967)').tap do |dir|
          dir.mkdir
          FileUtils.touch(dir.join('unknown.jpg'))
        end

        matching_directory_with_single_file = dir.join('Taxi Driver (1976)').tap do |dir|
          dir.mkdir
          FileUtils.touch(dir.join('source.mkv'))
        end

        matching_directory_with_multiple_files = dir.join('Scarface (1983)').tap do |dir|
          dir.mkdir
          FileUtils.touch(dir.join('one.mkv'))
          FileUtils.touch(dir.join('two.mkv'))
        end

        subject = described_class.new(dir)

        sources = subject.sources

        expect(sources.length).to eq(3)

        first, second, third = sources

        aggregate_failures do
          expect(first.movie.title).to eq('Scarface')
          expect(first.movie.year).to eq('1983')
          expect(first.relative_path).to eq('Scarface (1983)/one.mkv')
        end

        aggregate_failures do
          expect(second.movie.title).to eq('Scarface')
          expect(second.movie.year).to eq('1983')
          expect(second.relative_path).to eq('Scarface (1983)/two.mkv')
        end

        aggregate_failures do
          expect(third.movie.title).to eq('Taxi Driver')
          expect(third.movie.year).to eq('1976')
          expect(third.relative_path).to eq('Taxi Driver (1976)/source.mkv')
        end
      end
    end
  end
end
