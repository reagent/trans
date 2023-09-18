# frozen_string_literal: true

module Trans
  class ConfigurationFile
    class FileNotFoundError < Trans::Error
      def initialize(path)
        super("File not found: '#{path}'")
      end
    end

    class ParseError < Trans::Error
      def initialize(klass, message)
        super([klass, message].join(': '))
      end
    end

    def self.init(base, *rest)
      file = Pathname.new(base).join(*rest)

      if file.exist?
        load(base, *rest)
      else
        configuration = new({})
        configuration.write_to(base, *rest)
      end
    end

    def self.load(base, *rest)
      file = Pathname.new(base).join(*rest)

      raise FileNotFoundError, file unless file.exist?

      new(YAML.load_file(file))
    rescue Psych::Exception => e
      raise ParseError.new(e.class, e.message)
    end

    def initialize(deserialized)
      @deserialized = deserialized
    end

    def sources
      [configured, pending].flat_map(&:sources)
    end

    def pending
      @pending ||= group('pending')
    end

    def configured
      @configured ||= group('configured')
    end

    def to_h
      %w[configured pending].reduce({}) do |mapping, key|
        mapping.merge(key => send(key).to_h)
      end
    end

    def write_to(base, *path)
      file = Pathname.new(base).join(*path)
      file.write(YAML.dump(to_h))
      self
    end

    private

    def group(label)
      Group.new(label, @deserialized.fetch(label, []))
    end
  end
end
