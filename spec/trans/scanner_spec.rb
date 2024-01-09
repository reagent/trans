RSpec.describe Trans::Scanner do
  include Spec::FilesystemHelper

  describe '#with_media' do
    it 'has no entries when there are no directories' do
      with_temp_dir do |dir|
        entries = []

        subject = described_class.new(dir)
        subject.with_media { |medium| entries.push(medium) }

        expect(entries).to be_empty
      end
    end

    it 'movie single file' do
      with_temp_dir do |dir|
        entries = []

        parent = dir.join('Movie (1999)').tap(&:mkdir)
        FileUtils.touch(parent.join('file.mkv'))

        subject = described_class.new(dir)
        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(1)

        aggregate_failures do
          movie = entries.first
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie')
          expect(movie.year).to eq('1999')

          expect(movie.file.to_s).to eq('Movie (1999)/file.mkv')
        end
      end
    end

    it 'single movie, multiple files' do
      with_temp_dir do |dir|
        entries = []

        parent = dir.join('Movie (1999)').tap(&:mkdir)
        FileUtils.touch(parent.join('one.mkv'))
        FileUtils.touch(parent.join('two.mkv'))

        subject = described_class.new(dir)

        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(2)

        aggregate_failures do
          movie = entries.first
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie')
          expect(movie.year).to eq('1999')
          expect(movie.file.to_s).to eq('Movie (1999)/one.mkv')

          movie = entries.last
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie')
          expect(movie.year).to eq('1999')
          expect(movie.file.to_s).to eq('Movie (1999)/two.mkv')
        end
      end
    end

    it 'multiple movies' do
      with_temp_dir do |dir|
        entries = []

        parent_1 = dir.join('Movie (1999)').tap(&:mkdir)
        FileUtils.touch(parent_1.join('file.mkv'))

        parent_2 = dir.join('Movie 2 (2000)').tap(&:mkdir)
        FileUtils.touch(parent_2.join('file.mkv'))

        subject = described_class.new(dir)

        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(2)

        aggregate_failures do
          movie = entries.first
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie')
          expect(movie.year).to eq('1999')
          expect(movie.file.to_s).to eq('Movie (1999)/file.mkv')

          movie = entries.last
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie 2')
          expect(movie.year).to eq('2000')
          expect(movie.file.to_s).to eq('Movie 2 (2000)/file.mkv')
        end
      end
    end

    it 'episodic, flat' do
      with_temp_dir do |dir|
        entries = []

        parent = dir.join('The Office (2005)').tap(&:mkdir)
        FileUtils.touch(parent.join('S01E01.mkv'))
        FileUtils.touch(parent.join('S01E02.mkv'))

        subject = described_class.new(dir)

        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(1)

        aggregate_failures do
          tv_show = entries.first
          expect(tv_show).to be_instance_of(Trans::TvShow)

          expect(tv_show.files.length).to eq(2)
          expect(tv_show.files.first.identifier).to eq('S01E01')
          expect(tv_show.files.first.to_s).to eq('The Office (2005)/S01E01.mkv')

          expect(tv_show.files.last.identifier).to eq('S01E02')
          expect(tv_show.files.last.to_s).to eq('The Office (2005)/S01E02.mkv')
        end
      end
    end

    it 'episodic, nested' do
      with_temp_dir do |dir|
        entries = []

        parent = dir.join('The Office (2005)').tap(&:mkdir)
        season_1 = parent.join('Season 1').tap(&:mkdir)
        FileUtils.touch(season_1.join('S01E01.mkv'))
        season_2 = parent.join('Season 2').tap(&:mkdir)
        FileUtils.touch(season_2.join('S02E01.mkv'))

        subject = described_class.new(dir)

        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(1)

        aggregate_failures do
          tv_show = entries.first
          expect(tv_show).to be_instance_of(Trans::TvShow)

          expect(tv_show.title).to eq('The Office')
          expect(tv_show.year).to eq('2005')

          expect(tv_show.files.length).to eq(2)
          expect(tv_show.files.first.to_s).to eq('The Office (2005)/Season 1/S01E01.mkv')
          expect(tv_show.files.last.to_s).to eq('The Office (2005)/Season 2/S02E01.mkv')
        end
      end
    end

    it 'episodic, mixed' do
      with_temp_dir do |dir|
        entries = []

        movie = dir.join('Movie (1999)').tap(&:mkdir)
        FileUtils.touch(movie.join('file.mkv'))

        tv_show = dir.join('The Office (2005)').tap(&:mkdir)
        FileUtils.touch(tv_show.join('Season 1').tap(&:mkdir).join('S01E01.mkv'))

        subject = described_class.new(dir)

        subject.with_media { |medium| entries.push(medium) }

        expect(entries.length).to eq(2)

        aggregate_failures do
          movie = entries.first
          expect(movie).to be_instance_of(Trans::Movie)

          expect(movie.title).to eq('Movie')
          expect(movie.year).to eq('1999')
          expect(movie.file.to_s).to eq('Movie (1999)/file.mkv')

          tv_show = entries.last
          expect(tv_show).to be_instance_of(Trans::TvShow)

          expect(tv_show.title).to eq('The Office')
          expect(tv_show.year).to eq('2005')

          expect(tv_show.files.map(&:to_s)).to \
            eq(['The Office (2005)/Season 1/S01E01.mkv'])
        end
      end
    end
  end
end
