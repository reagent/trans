# frozen_string_literal: true

require 'trans/version'
require 'pathname'
require 'yaml'

module Trans
  class Error < StandardError; end

  autoload :Movie, 'trans/movie'
  autoload :Source, 'trans/source'
  autoload :SourceDirectory, 'trans/source_directory'
  autoload :DestinationDirectory, 'trans/destination_directory'
  autoload :DestinationFile, 'trans/destination_file'
  autoload :Stanza, 'trans/stanza'
  autoload :ConfigurationFile, 'trans/configuration_file'
  autoload :Group, 'trans/group'
  autoload :Scanner, 'trans/scanner'
  autoload :Transcoder, 'trans/transcoder'
end
