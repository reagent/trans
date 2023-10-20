RSpec.describe Trans::Source do
  include Spec::FilesystemHelper

  describe 'sorting' do
    it 'sorts based on name and year' do
      movie_1 = Trans::Movie.new('Z', '1999')
      source_1 = described_class.new(movie_1, Pathname.new('.'))

      movie_2 = Trans::Movie.new('Z', '1998')
      source_2 = described_class.new(movie_2, Pathname.new('.'))

      movie_3 = Trans::Movie.new('A', '1977')
      source_3 = described_class.new(movie_3, Pathname.new('.'))

      expect([source_1, source_2, source_3].sort).to \
        eq([source_3, source_2, source_1])
    end
  end

  describe '#==' do
    it 'is unequal when provided with different movies' do
      movie_1 = Trans::Movie.new('The Goonies', '1985')
      movie_2 = Trans::Movie.new('Taxi Driver', '1976')

      one = described_class.new(movie_1, Pathname.new('Source').join('one.mkv'))
      two = described_class.new(movie_2, Pathname.new('Source').join('one.mkv'))

      expect(one).not_to eq(two)
    end

    it 'is not equal when provided with the same movie but different files' do
      movie = Trans::Movie.new('The Goonies', '1985')

      one = described_class.new(movie, Pathname.new('Source').join('one.mkv'))
      two = described_class.new(movie, Pathname.new('Source').join('two.mkv'))

      expect(one).not_to eq(two)
    end

    it 'is equal when provided with the same movie and same files' do
      movie = Trans::Movie.new('The Goonies', '1985')

      one = described_class.new(movie, Pathname.new('Source').join('one.mkv'))
      two = described_class.new(movie, Pathname.new('Source').join('one.mkv'))

      expect(one).to eq(two)
    end
  end
end
