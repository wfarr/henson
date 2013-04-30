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
          begin
            response = request :get, found["tarball_url"], options

            write_download destination, response.body
          rescue Henson::APIError => e
            raise Henson::GitHubDownloadError
          end
        else
          raise "invalid tag #{tag} given for repository #{repository}"
        end
      end

      private

      def write_download file, content
        File.open file, "wb+" do |f|
          file.write content
        end
      end
    end
  end
end
