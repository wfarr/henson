require "pathname"
require "rubygems/package"

module Henson
  module Source
    class Tarball < Generic

      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Check if the module tarball has been cached.
      #
      # Returns True if the module tarball exists on disk, otherwise False.
      def fetched?
        cache_path.file?
      end

      # Public: Determine the version of the module to be installed.
      #
      # Returns the String version number.
      def version
        @version ||= resolve_version_from_requirement(@requirement)
      end

      # Public: Fetch a list of all candidate versions from the forge
      #
      # Returns an Array of versions as Strings.
      def versions
        @versions ||= fetch_versions_from_api
      end

      # Public: Install the module into the install path. If a version of the
      # module has already been installed, it will first be removed.
      #
      # Returns nothing.
      def install!
        install_path.rmtree if install_path.exist?
        install_path.mkpath
        extract_tarball cache_path.to_path, install_path.to_path
      end
    end
  end
end
