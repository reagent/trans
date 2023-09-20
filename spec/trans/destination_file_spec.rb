RSpec.describe Trans::DestinationFile do
  include Spec::FilesystemHelper

  context 'with a movie' do
    let(:movie) { Trans::Movie.new('The Goonies', '1985') }

    describe '#dir' do
      it 'returns the full path to the named destination directory' do
        with_temp_dir do |path|
          subject = described_class.new(movie, path:)
          expect(subject.dir).to eq(path.join('The Goonies (1985)'))
        end
      end
    end

    describe '#filename' do
      it 'generates a filename based on the movie name' do
        with_temp_dir do |path|
          subject = described_class.new(movie, path:)
          expect(subject.filename).to eq('The_Goonies.mkv')
        end
      end
    end

    describe '#full_path' do
      it 'generates the full path to the destination file' do
        with_temp_dir do |path|
          subject = described_class.new(movie, path:)

          expect(subject.full_path).to \
            eq(path.join('The Goonies (1985)', 'The_Goonies.mkv'))
        end
      end
    end
  end
end
