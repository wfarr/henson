module Henson
  module Source
    class Path < Generic
      attr_reader :path

      def initialize(path)
        @path = path

        raise ModuleNotFound, path unless valid?
      end

      def fetch!
        Henson.ui.debug "Fetching #{path}..."
        Henson.ui.info  "Fetching #{path}..."
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
        DSL::Modulefile.evaluate(File.join(path, 'Modulefile')).version
      end
    end
  end
end
