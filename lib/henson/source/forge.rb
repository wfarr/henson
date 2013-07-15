require "henson/source/tarball"

module Henson
  module Source
    class Forge < Tarball

      # Public: Initialize a new Henson::Source::Forge
      #
      # name        - The String name of the module.
      # requirement - The Gem::Requirement used to satisfy versions.
      # forge       - The String hostname of the Puppet Forge.
      def initialize name, requirement, forge
        @api = Henson.api_clients.puppet_forge forge

        super
      end

      # Public: Check if the module has been installed.
      #
      # Returns True if the module exists in the install path, otherwise False.
      def installed?
        # TODO: Check if Modulefile exists.  If it exists, get the version
        # and check if it needs installing.  Otherwise, assume uninstalled.
        false
      end

      private

      # Internal: Fetch a list of all candidate versions from the forge
      #
      # Returns an Array of versions as Strings.
      def fetch_versions_from_api
        @api.versions_for_module name
      end

      # Internal: Download the module to the cache.
      def download!
        Henson.ui.debug "Downloading #{name}@#{version} to #{cache_path}"
        @api.download_version_for_module name, version, cache_path.to_path
      end
    end
  end
end
