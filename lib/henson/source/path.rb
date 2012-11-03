module Henson
  module Source
    class Path < Generic
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def fetch!
      end

      def versions
        # Obviously, when the modulespec stuff is written we'd want to try that
        # first and then fall back to the Modulefile if necessary.
        [version_from_modulefile]
      end

    private
      def valid?
        path_exists?
      end

      def path_exists?
        path && File.directory?(path)
      end

      def version_from_modulefile
        if path_exists?
          modulefile_path = File.join(path, 'Modulefile')
          modulefile_contents = File.readlines(modulefile_path)
          version_line = modulefile_contents.grep(/\A\s*version\s+[\d\.]+\s*\Z/).first
          if version_line.nil?
            # TODO raise error that modulefile didn't contain a version line
          else
            version_line.strip.split(/\s+/).last
          end
        else
          raise ModuleNotFound, path
        end
      end
    end
  end
end
