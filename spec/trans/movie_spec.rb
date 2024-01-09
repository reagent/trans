RSpec.describe Trans::Movie do
  let(:file) { Pathname.new('file.mkv') }

  describe '#title' do
    it 'returns the title' do
      subject = described_class.new('The Goonies', '1985', file)
      expect(subject.title).to eq('The Goonies')
    end
  end

  describe '#year' do
    it 'returns the year' do
      subject = described_class.new('The Goonies', '1985', file)
      expect(subject.year).to eq('1985')
    end
  end

  describe '#==' do
    it 'is not equal when given different titles and years' do
      one = described_class.new('The Goonies', '1985', file)
      two = described_class.new('Raiders of the Lost Ark', '1983', file)

      expect(one).to_not eq(two)
    end

    it 'is not equal when given the same title and different years' do
      one = described_class.new('Suspiria', '1977', file)
      two = described_class.new('Suspiria', '2018', file)

      expect(one).to_not eq(two)
    end

    it 'is not equal when given different titles and the same year' do
      one = described_class.new('Star Wars', '1977', file)
      two = described_class.new('Suspiria', '1977', file)

      expect(one).to_not eq(two)
    end

    it 'is equal when given the same title and year' do
      one = described_class.new('Star Wars', '1977', file)
      two = described_class.new('Star Wars', '1977', file)

      expect(one).to eq(two)
    end
  end
end
