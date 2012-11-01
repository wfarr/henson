module Henson
  module Source
    class Path < Generic
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def fetch!
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
          if File.file? modulefile_path
            modulefile_contents = File.readlines(modulefile_path)
            version_line = modulefile_contents.grep(/\A\s*version\s+[\d\.]+\s*\Z/).first
            if version_line.nil?
              # TODO raise error that modulefile didn't contain a version line
            else
              version_line.strip.split(/\s+/).last
            end
          else
            # TODO raise error that the module didn't contain a modulefile
          end
        else
          raise Henson::ModuleNotFound, path
        end
      end
    end
  end
end
