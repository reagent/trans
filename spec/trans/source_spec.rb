RSpec.describe Trans::Source do
  include Spec::FilesystemHelper

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
