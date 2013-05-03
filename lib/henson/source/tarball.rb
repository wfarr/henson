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
    end
  end
end
