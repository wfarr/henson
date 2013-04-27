require 'uri'
require 'net/https'
require 'json'
require 'pathname'
require 'rubygems/package'

module Henson
  module Source
    class GitHubTarball < Generic
      attr_reader :name, :repo, :version

      def initialize(name, requirement, repo)
        @name = name
        @repo = repo
        @requirement = requirement
        @version = resolve_version_from_requirement(@requirement)
      end

      def fetched?
        tarball_path.file?
      end

      def fetch!
        clean_up_old_cached_versions

        url = "https://api.github.com/repos/#{repo}/tarball/#{version}"
        if ENV['GITHUB_API_TOKEN']
          url << "?access_token=#{ENV['GITHUB_API_TOKEN']}"
        end

        # TODO: Error checking!
        download_file url, tarball_path.to_path
      end

      def install!
        install_path.rmtree if install_path.exist?
        install_path.mkpath
        extract_tarball tarball_path.to_path, install_path.to_path
      end

      def installed?
        # TODO: Check if Modulefile exists.  If it exists, get the version
        # and check if it needs installing.  Otherwise, assume uninstalled.
        false
      end

      def versions
        @versions ||= fetch_versions_from_api
      end

      private
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
        if response.code.to_i != 200
          nil
          # TODO: raise a friendly error here
        else
          data = response.body
          JSON.parse(data)
        end
      end

      def fetch_versions_from_api
        data = api_call("/repos/#{repo}/tags")
        if data.nil?
          # TODO raise error
        end

        data.map { |r|
          r['name']
        }.map { |version|
          version.gsub(/\Av/, '')
        }.delete_if { |version|
          version !~ /\A\d+\.\d+(\.\d+.*)?\Z/
        }.compact
      end

      def download_file(source, dest)
        uri = URI.parse(source)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.start do |h|
          req = Net::HTTP::Get.new(uri.request_uri)
          req.add_field "User-Agent", "henson v#{Henson::VERSION}"
          resp = h.request(req)
          if ["301", "302"].include? resp.code
            download_file(resp.header['location'], dest)
          # TODO: Handle error cases
          else
            File.open(dest, 'wb') { |f| f.write resp.body }
          end
        end
      end

      def extract_tarball(tarball, dest)
        Gem::Package::TarReader.new(Zlib::GzipReader.open(tarball)).each do |entry|
          entry_name = entry.full_name.split('/')[1..-1].join('/')
          if entry.file?
            File.open("#{dest}/#{entry_name}", 'wb') { |f| f.write entry.read }
          elsif entry.directory?
            Pathname.new("#{dest}/#{entry_name}").mkpath
          end
        end
      end

      def cache_path
        @cache_path ||= lambda {
          path = Pathname.new(Henson.settings[:cache_path]) + 'github_tarball'
          path.mkpath
          path.realpath
        }.call
      end

      def tarball_path
        @tarball_path ||= cache_path + "#{repo.gsub('/', '-')}-#{version}.tar.gz"
      end

      def clean_up_old_cached_versions
        Dir["#{cache_path.to_path}/#{repo.gsub('/', '-')}*.tar.gz"].each do |f|
          FileUtils.rm f
        end
      end

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
