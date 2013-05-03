require "henson/source/tarball"

module Henson
  module Source
    class GitHub < Tarball

      # Public: Returns the String repo of the module.
      attr_reader :repo

      # Public: Initialise a new Henson::Source::GitHub.
      #
      # name        - The String name of the module.
      # requirement - The String version requirement for the module.
      # repo        - The String GitHub repository to pull the module from
      #               (e.g. "puppetlabs/puppetlabs-stdlib").
      def initialize name, requirement, repo
        @repo = repo
        @api  = Henson.api_clients.github "https://api.github.com/"

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

      # Internal: Query the GitHub API for a list of tag names that look like
      # version numbers. If the tag name starts with a v (e.g. v0.0.1), it will
      # be stripped.
      #
      # Returns an Array of String version numbers.
      def fetch_versions_from_api
        Henson.ui.debug "Fetching a list of tag names for #{repo}"

        @api.tags_for_repo(repo).collect { |tag|
          tag["name"]
        }.delete_if { |tag|
          tag !~ /\Av?\d+\.\d+(\.\d+.*)?\z/
        }.collect { |tag|
          tag.gsub /\Av/, ""
        }.compact
      end

      # Internal: Download the module to the cache.
      def download!
        Henson.ui.debug "Downloading #{repo}@#{version} to #{cache_path}..."
        @api.download_tag_for_repo repo, version, cache_path.to_path
      end

      # Internal: Array of files to clean up before installing a module.
      def cached_versions_to_clean
        "#{cache_dir.to_path}/#{repo.gsub("/", "-")}-*.tar.gz"
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
