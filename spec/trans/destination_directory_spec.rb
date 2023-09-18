RSpec.describe Trans::DestinationDirectory do
  include Spec::FilesystemHelper
  describe '#completed' do
    it 'returns a list of completed movies' do
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

        subject = described_class.new(dir)
        completed = subject.completed

        expect(completed.length).to eq(1)

        aggregate_failures do
          expect(completed.first).to be_instance_of(Trans::Movie)
          expect(completed.first.title).to eq('Taxi Driver')
          expect(completed.first.year).to eq('1976')
        end
      end
    end
  end
end
