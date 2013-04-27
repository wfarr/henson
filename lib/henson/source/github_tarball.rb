require 'uri'
require 'net/https'
require 'json'
require 'pathname'
require 'rubygems/package'

module Henson
  module Source
    class GitHubTarball < Generic
      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Returns the String repo of the module.
      attr_reader :repo

      # Public: Returns the String version number of the module.
      attr_reader :version

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
        @version = resolve_version_from_requirement(@requirement)
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
        clean_up_old_cached_versions

        url = "https://api.github.com/repos/#{repo}/tarball/#{version}"
        if ENV['GITHUB_API_TOKEN']
          url << "?access_token=#{ENV['GITHUB_API_TOKEN']}"
        end

        download_file url, tarball_path.to_path
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

      # Internal: Make a call to the GitHub API.
      #
      # path - The URI String under https://api.github.com to request (e.g.
      # /repos/puppetlabs/puppetlabs-stdlib/tags).
      #
      # Returns the parsed JSON object (probably a Hash).
      def api_call(path)
        url = "https://api.github.com#{path}"
        if ENV['GITHUB_API_TOKEN']
          url << "?access_token=#{ENV['GITHUB_API_TOKEN']}"
        end

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field "User-Agent", "henson v#{Henson::VERSION}"

        response = http.request(request)
        if response.code == "404"
          raise GitHubTarballNotFound, "Unable to find #{repo} on GitHub"
        elsif response.is_a? Net::HTTPSuccess
          data = response.body
          JSON.parse(data)
        else
          raise GitHubAPIError, "GitHub API returned #{response.code} for #{uri}"
        end
      end

      # Internal: Query the GitHub API for a list of tag names that look like
      # version numbers. If the tag name starts with a v (e.g. v0.0.1), it will
      # be stripped.
      #
      # Returns an Array of String version numbers.
      def fetch_versions_from_api
        Henson.ui.debug "Fetching a list of tag names for #{repo}"

        data = api_call("/repos/#{repo}/tags")
        if data.nil?
          raise GitHubAPIError,
            "No data returned from https://api.github.com/repos/#{repo}/tags"
        end

        data.map { |r|
          r['name']
        }.map { |version|
          version.gsub(/\Av/, '')
        }.delete_if { |version|
          version !~ /\A\d+\.\d+(\.\d+.*)?\Z/
        }.compact
      end

      # Internal: Download a file, following redirects.
      #
      # source - The String URL to download.
      # dest   - The String path on disk (including filename) that the file
      #          should be downloaded to.
      #
      # Returns nothing.
      def download_file(source, dest)
        Henson.ui.debug "Downloading #{source} to #{dest}"

        uri = URI.parse(source)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.start do |h|
          req = Net::HTTP::Get.new(uri.request_uri)
          req.add_field "User-Agent", "henson v#{Henson::VERSION}"
          resp = h.request(req)
          if resp.is_a? Net::HTTPSuccess
            File.open(dest, 'wb') { |f| f.write resp.body }
          elsif ["301", "302"].include? resp.code
            Henson.ui.debug "Following redirect to #{resp.header['location']}"
            download_file(resp.header['location'], dest)
          else
            raise GitHubDownloadError, "GitHub returned #{resp.code} for #{source}"
          end
        end
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
          entry_name = entry.full_name.split('/')[1..-1].join('/')
          if entry.file?
            File.open("#{dest}/#{entry_name}", 'wb') { |f| f.write entry.read }
          elsif entry.directory?
            Pathname.new("#{dest}/#{entry_name}").mkpath
          end
        end
      end

      # Internal: Create and return the path where the module tarballs will be
      # cached.
      #
      # Returns the Pathname object for the directory.
      def cache_path
        @cache_path ||= lambda {
          path = Pathname.new(Henson.settings[:cache_path]) + 'github_tarball'
          path.mkpath
          path.realpath
        }.call
      end

      # Internal: Return the path where the tarball for this version of the
      # module will be stored.
      #
      # Returns the Pathname object for the tarball.
      def tarball_path
        @tarball_path ||= cache_path + "#{repo.gsub('/', '-')}-#{version}.tar.gz"
      end

      # Internal: Remove all tarballs for the module from the cache directory.
      #
      # Returns nothing.
      def clean_up_old_cached_versions
        Dir["#{cache_path.to_path}/#{repo.gsub('/', '-')}*.tar.gz"].each do |f|
          FileUtils.rm f
        end
      end

      # Internal: Create and return the path that the module will be installed
      # to.
      #
      # Returns the Pathname object for the directory.
      def install_path
        @install_path ||= lambda {
          path = Pathname.new(Henson.settings[:path]) + name
          path.mkpath
          path.realpath
        }.call
      end
    end
  end
end
