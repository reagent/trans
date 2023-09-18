require 'tempfile'

module Spec
  module FilesystemHelper
    private

    def with_temp_dir
      Dir.mktmpdir { |d| yield Pathname.new(d) }
    end
  end
end
