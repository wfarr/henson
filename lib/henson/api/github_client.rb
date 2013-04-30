require "henson/api/client"

module Henson
  module API
    class GitHubClient < Client
      def after_initialize
        @tag_cache = {}
      end

      def tags_for_repo repository, options = {}
        @tag_cache[repository] ||=
          request :get, "/repos/#{repository}/tags", options
      end

      def download_tag_for_repo repository, tag, destination, options = {}
        tags = tags_for_repo repository

        if found = tags.detect { |t| t["name"] =~ /\Av?#{tag}\z/ }
          response = request :get, found["tarball_url"], options

          File.open destination, "wb+" do |file|
            file.write response.body
          end
        else
          raise "invalid tag #{tag} given for repository #{repository}"
        end
      rescue Faraday::ClientError => e
        raise GitHubDownloadError, "GitHub returned #{resp.code} for #{source}"
      end
    end
  end
end
