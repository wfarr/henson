require "fileutils"

module Henson
  module Source
    class Path < Generic
      attr_reader :path, :name

      def initialize name, path
        @path = path
        @name = name

        raise ModuleNotFound, path unless valid?
      end

      def fetched?
        true
      end

      def fetch!
        # noop
      end

      def install!
        Henson.ui.debug "Symlinking #{path} to #{install_path}"
        FileUtils.ln_sf path, install_path.to_path
      end

      def versions
        # Obviously, when the modulespec stuff is written we"d want to try that
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

      def install_path
        @install_path ||= Pathname.new(Henson.settings[:path]) + name
      end

      def version_from_modulefile
        DSL::Modulefile.evaluate(File.join(path, "Modulefile")).version
      rescue ModulefileNotFound
        "0"
      end
    end
  end
end
