module Henson
  module Source
    class Forge < Generic

      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Returns the String name of the forge.
      attr_reader :api


      # Public: Initialize a new Henson::Source::Forge
      #
      # name  - The String name of the module.
      # forge - The String hostname of the Puppet Forge.
      def initialize name, requirement, forge
        @name  = name
        @api   = Henson.api_clients.puppet_forge forge

        @requirement = requirement
      end

      # Public: Determine whether the download needs fetched.
      #
      # Returns True if the download is not required, False otherwise.
      def fetched?
        cache_path.file?
      end

      # Public: Determine the version of the module to be installed.
      #
      # Returns the String version number.
      def version
        @version ||= resolve_version_from_requirement(@requirement)
      end

      # Public: Fetches the tarball for the module and caches it.
      def fetch!
        cache_dir.mkpath

        clean_up_old_cached_versions

        download_module!
      end

      def install!
        # TODO implement me
      end

      # Internal: Fetch a list of all candidate versions from the forge
      #
      # Returns an Array of versions as Strings.
      def versions
        @versions ||= api.versions_for_module name
      end

      private

      # Internal: Download the module to the cache.
      def download_module!
        api.download_version_for_module name, version, cache_path
      end

      # Internal: Return the dir where the module tarballs will be cached.
      #
      # Returns the Pathname object for the directory.
      def cache_dir
        @cache_dir ||= Pathname.new(Henson.settings[:cache_path]) + "forge"
      end

      # Internal: Return the path where the tarball for this version of the
      # module will be stored.
      #
      # Returns the Pathname object for the tarball.
      def cache_path
        @cache_path ||= cache_dir + "#{name.gsub("/", "-")}-#{version}.tar.gz"
      end

      # Internal: Remove all tarballs for the module from the cache directory.
      #
      # Returns nothing.
      def clean_up_old_cached_versions
        Dir["#{cache_dir.to_path}/#{name.gsub("/", "-")}-*.tar.gz"].each do |f|
          FileUtils.rm f
        end
      end
    end
  end
end
