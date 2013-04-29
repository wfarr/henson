require "uri"
require "net/https"
require "json"
require "pathname"
require "rubygems/package"

module Henson
  module Source
    class GitHubTarball < Generic
      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Returns the String repo of the module.
      attr_reader :repo

      # Public: Initialise a new Henson::Source::GitHubTarball.
      #
      # name        - The String name of the module.
      # requirement - The String version requirement for the module.
      # repo        - The String GitHub repository to pull the module from
      #               (e.g. "puppetlabs/puppetlabs-stdlib").
      def initialize(name, requirement, repo)
        @name = name
        @repo = repo
        @requirement = requirement
      end

      # Public: Determine the version of the module to be installed.
      #
      # Returns the String version number.
      def version
        @version ||= resolve_version_from_requirement(@requirement)
      end

      # Public: Check if the module tarball has been cached.
      #
      # Returns True if the module tarball exists on disk, otherwise False.
      def fetched?
        tarball_path.file?
      end

      # Public: Cache the module tarball on disk. Any tarballs for previous
      # versions of this module will be removed.
      #
      # Returns nothing.
      def fetch!
        cache_path.mkpath

        clean_up_old_cached_versions

        download_tag_tarball tarball_path.to_path
      end

      # Public: Install the module into the install path. If a version of the
      # module has already been installed, it will first be removed.
      #
      # Returns nothing.
      def install!
        install_path.rmtree if install_path.exist?
        install_path.mkpath
        extract_tarball tarball_path.to_path, install_path.to_path
      end

      # Public: Check if the module has been installed.
      #
      # Returns True if the module exists in the install path, otherwise False.
      def installed?
        # TODO: Check if Modulefile exists.  If it exists, get the version
        # and check if it needs installing.  Otherwise, assume uninstalled.
        false
      end

      def versions
        @versions ||= fetch_versions_from_api
      end

      private

      # Internal: Query the GitHub API for a list of tag names that look like
      # version numbers. If the tag name starts with a v (e.g. v0.0.1), it will
      # be stripped.
      #
      # Returns an Array of String version numbers.
      def fetch_versions_from_api
        Henson.ui.debug "Fetching a list of tag names for #{repo}"

        Henson.api_client.tags_for_repo(repo).collect { |tag|
          tag["name"]
        }.delete_if { |tag|
          tag !~ /\Av?\d+\.\d+(\.\d+.*)?\z/
        }.collect { |tag|
          tag.gsub /\Av/, ""
        }.compact
      end

      # Internal: Download a file, following redirects.
      #
      # dest   - The String path on disk (including filename) that the file
      #          should be downloaded to.
      #
      # Returns nothing.
      def download_tag_tarball dest
        Henson.ui.debug "Downloading #{repo}@#{version} to #{dest}..."
        Henson.api_client.download_tag_for_repo repo, version, dest
      end

      # Internal: Extract a tarball to a specified destination, stripping the
      # first component from the paths in the tarball.
      #
      # tarball - The String path on disk to the tarball.
      # dest    - The String path on disk to the directory that the tarball
      #           will be extracted into.
      #
      # Returns nothing.
      def extract_tarball(tarball, dest)
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
      def cache_path
        @cache_path ||= Pathname.new(Henson.settings[:cache_path]) + "github_tarball"
      end

      # Internal: Return the path where the tarball for this version of the
      # module will be stored.
      #
      # Returns the Pathname object for the tarball.
      def tarball_path
        @tarball_path ||= cache_path + "#{repo.gsub("/", "-")}-#{version}.tar.gz"
      end

      # Internal: Remove all tarballs for the module from the cache directory.
      #
      # Returns nothing.
      def clean_up_old_cached_versions
        Dir["#{cache_path.to_path}/#{repo.gsub("/", "-")}-*.tar.gz"].each do |f|
          FileUtils.rm f
        end
      end

      # Internal: Return the path that the module will be installed to.
      #
      # Returns the Pathname object for the directory.
      def install_path
        @install_path ||= Pathname.new(Henson.settings[:path]) + name
      end
    end
  end
end
