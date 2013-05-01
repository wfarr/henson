require "henson/api/client"

module Henson
  module API
    class PuppetForgeClient < Client
      # Private: Initializes the local client cache of API responses.
      def after_initialize
        @cache = {}
      end

      # Public: Download a tag for a repository.
      #
      # mod         - The String in form username/reponame on GitHub.
      # version     - The String representing the version number.
      # destination - The String path to where the download should be saved.
      # options     - The optional Hash of URL options
      #
      # Raises Henson::PuppetForgeDownloadError if the download fails.
      # Raises Henson::PuppetModuleNotFound if the module/version is invalid.
      def download_version_for_module mod, version, destination, options = {}
        releases = get_module(mod, options)["releases"]

        if releases.any? { |r| r["version"] == version }
          begin
            download "#{mod}/#{version}.tar.gz", destination, options

          rescue Henson::APIError => e
            raise Henson::PuppetForgeDownloadError,
              "Download of #{mod} failed!"
          end

        else
          raise Henson::PuppetModuleNotFound,
            "Invalid version #{version} for #{mod}"
        end
      end

      # Public: List all candidate versions for a module.
      #
      # mod     - The String name of the module in the form <owner>/<name>
      # options - The optional Hash request options.
      #
      # Returns an Array of versions as Strings.
      def versions_for_module mod, options = {}
        get_module(mod, options)["releases"].map { |r|
          r["version"]
        }.sort.reverse
      end

      # Internal: Retrieve a Puppet module via the Forge API.
      #
      # mod     - The String name of the module in the form <owner>/<name>
      # options - The optional Hash request options.
      #
      # Returns a Hash of the module metadata.
      def get_module mod, options = {}
        @cache[mod] ||= request :get, mod, options
      rescue Henson::APIError
        raise Henson::PuppetModuleNotFound,
          "The forge at #{connection.url_prefix} does not have any module #{mod}!"
      end
    end
  end
end
