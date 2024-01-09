RSpec.describe Trans::Source do
  include Spec::FilesystemHelper

  let(:file) { Pathname.new('file.mkv') }

  describe 'sorting' do
    it 'sorts based on name and year' do
      movie_1 = Trans::Movie.new('Z', '1999', file)
      source_1 = described_class.new(movie_1)

      movie_2 = Trans::Movie.new('Z', '1998', file)
      source_2 = described_class.new(movie_2)

      movie_3 = Trans::Movie.new('A', '1977', file)
      source_3 = described_class.new(movie_3)

      expect([source_1, source_2, source_3].sort).to \
        eq([source_3, source_2, source_1])
    end
  end

  describe '#==' do
    it 'is unequal when provided with different movies' do
      movie_1 = Trans::Movie.new('The Goonies', '1985', file)
      movie_2 = Trans::Movie.new('Taxi Driver', '1976', file)

      one = described_class.new(movie_1)
      two = described_class.new(movie_2)

      expect(one).not_to eq(two)
    end

    xit 'is not equal when provided with the same movie but different files' do
      movie = Trans::Movie.new('The Goonies', '1985', file)

      one = described_class.new(movie)
      two = described_class.new(movie)

      expect(one).not_to eq(two)
    end

    xit 'is equal when provided with the same movie and same files' do
      movie = Trans::Movie.new('The Goonies', '1985', file)

      one = described_class.new(movie)
      two = described_class.new(movie)

      expect(one).to eq(two)
    end
  end
end
