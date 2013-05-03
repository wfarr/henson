require "pathname"
require "rubygems/package"

# Public: This class implements a generic tarball source for a remote API.
#   Your class should inherit from this class if it utilizes tarballs caching.
#
#   There are 2 methods all subclasses must implement to function:
#
#     - fetch_versions_from_api - Returns Array of version numbers as Strings
#     - download! - Should download a tarball to `cache_path.to_path`
#
#   Additionally, you will want to provide your own initializer that takes at
#   least two arguments (name and requirement) and assigns @api to some API
#   client.
#
module Henson
  module Source
    class Tarball < Generic

      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Returns the API client object
      attr_reader :api

      # Public: Initialise a new Henson::Source::Tarball.
      #
      # name        - The String name of the module.
      # requirement - The String version requirement for the module.
      # context     - Any object to establish context for the subclass.
      #
      # Returns an instance of the class.
      def initialize name, requirement, *args
        @name ||= name
        @requirement ||= requirement

        self
      end

      # Public: Check if the module tarball has been cached.
      #
      # Returns True if the module tarball exists on disk, otherwise False.
      def fetched?
        cache_path.file?
      end

      # Public: Cache the module tarball on disk. Any tarballs for previous
      # versions of this module will be removed.
      #
      # Returns nothing.
      def fetch!
        cache_dir.mkpath
        clean_up_old_cached_versions
        download!
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
        cache_path.rmtree if Henson.settings[:no_cache]
      end

      private

      def fetch_versions_from_api
        raise NotImplementedError
      end

      def download!
        raise NotImplementedError
      end

      # Internal: Extract a tarball to a specified destination, stripping the
      # first component from the paths in the tarball.
      #
      # tarball - The String path on disk to the tarball.
      # dest    - The String path on disk to the directory that the tarball
      #           will be extracted into.
      #
      # Returns nothing.
      def extract_tarball tarball, dest
        Henson.ui.debug "Extracting #{tarball} to #{dest}"

        Gem::Package::TarReader.new(Zlib::GzipReader.open(tarball)).each do |entry|
          entry_name = entry.full_name.split("/")[1..-1].join("/")

          if entry.file?
            File.open("#{dest}/#{entry_name}", "wb") { |f| f.write entry.read }
          elsif entry.directory?
            FileUtils.mkdir_p "#{dest}/#{entry_name}"
          end
        end
      end

      # Internal: Return the path where the module tarballs will be cached.
      #
      # Returns the Pathname object for the directory.
      def cache_dir
        @cache_dir ||=
          Pathname.new(Henson.settings[:cache_path]) + source_class.downcase
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
        versions_to_clean = cache_path.to_path.gsub \
          /#{Regexp.escape(version)}/, "*"

        Dir[versions_to_clean].each do |f|
          FileUtils.rm f
        end
      end

      # Internal: Return the path that the module will be installed to.
      #
      # Returns the Pathname object for the directory.
      def install_path
        @install_path ||=
          Pathname.new(Henson.settings[:path]) + name.rpartition("/").last
      end

      # Internal: The last segment of the class name
      def source_class
        @source_class ||= self.class.name.rpartition("::").last
      end
    end
  end
end
