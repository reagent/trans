# frozen_string_literal: true

module Trans
  class ConfigurationFile
    FileExistsError = Class.new(Trans::Error)

    class MissingConfigurationError < Trans::Error
      def initialize(key)
        super("Missing configuration key: `#{key}`")
      end
    end

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

    extend Forwardable

    def_delegators :@sources, :pending, :configured

    def self.create(path, source_path:, destination_path:)
      path = Pathname(path)
      raise FileExistsError, path if path.exist?

      configuration = new(
        {
          'locations' => {
            'source' => source_path,
            'destination' => destination_path
          }
        }
      )

      configuration.write_to(path)
    end

    def self.load(base, *rest)
      file = Pathname.new(base).join(*rest)

      raise FileNotFoundError, file unless file.exist?

      new(YAML.load_file(file))
    rescue Psych::Exception => e
      raise ParseError.new(e.class, e.message)
    end

    attr_reader :locations

    def initialize(attributes)
      location_attributes = attributes.fetch('locations') do
        raise MissingConfigurationError, 'locations'
      end

      @locations = Locations.new(location_attributes)
      @sources = Sources.new(attributes.fetch('sources', {}))
    end

    def source_directory
      SourceDirectory.new(@locations.source)
    end

    def destination_directory
      DestinationDirectory.new(@locations.destination)
    end

    def sources
      @sources.all.sort
    end

    def to_h
      {
        'locations' => @locations.to_h,
        'sources' => @sources.to_h
      }
    end

    def write_to(base, *path)
      file = Pathname.new(base).join(*path)
      file.write(YAML.dump(to_h))
      self
    end

    autoload :Locations, 'trans/configuration_file/locations'
    autoload :Sources, 'trans/configuration_file/sources'
  end
end
