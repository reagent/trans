# frozen_string_literal: true

module Trans
  class File
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def basename
      @path.basename
    end

    def to_s
      @path.to_s
    end
  end

  class EpisodicFile
    attr_reader :path, :identifier

    def initialize(path, identifier)
      @path = path
      @identifier = identifier
    end

    def to_s
      @path.to_s
    end
  end

  class DirectoryTraverser
    def initialize(path)
      @path = path
    end

    def files
      @path.children.reject(&:directory?) + directories.flat_map(&:files)
    end

    def directories
      @path.children.select(&:directory?).map do |d|
        self.class.new(@path.join(d))
      end
    end
  end

  class FileCollection
    extend Forwardable

    def_delegators :transcodable, :empty?

    def initialize(root, dir)
      @root = root
      @dir = dir
    end

    def episodic
      pattern = /^(?<identifier>S\d{2}E\d{2})\.mkv$/

      all.select { |f| f.basename.to_s.match?(pattern) }.map do |file|
        matches = file.basename.to_s.match(pattern)

        EpisodicFile.new(
          @dir.join(file),
          matches.named_captures['identifier']
        )
      end
    end

    def transcodable
      all
        .select { |f| f.to_s.end_with?('.mkv') }
        .map { |f| File.new(@dir.join(f)) }
    end

    def full_path
      @root.join(@dir)
    end

    private

    def all
      DirectoryTraverser.new(full_path).files.sort.map do |f|
        f.relative_path_from(full_path)
      end
    end
  end

  class TvShow
    attr_reader :title, :year, :files

    def initialize(title, year, files)
      @title = title
      @year = year
      @files = files
    end
  end

  class Scanner
    DIRECTORY_NAME_PATTERN = /\A(?<title>.+)\s+\((?<year>\d{4})\)\Z/

    def initialize(path)
      @path = path
    end

    def with_media(&)
      @path.entries.sort.each do |dir|
        next unless (matches = dir.to_s.match(DIRECTORY_NAME_PATTERN))

        files = FileCollection.new(@path, dir)

        next if files.empty?

        title = matches.named_captures['title']
        year = matches.named_captures['year']

        if files.episodic.any?
          yield TvShow.new(title, year, files.episodic)
        else
          files.transcodable.each do |file|
            yield Movie.new(title, year, file)
          end
        end
      end
    end
  end
end
