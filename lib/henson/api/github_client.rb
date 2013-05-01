require "henson/api/client"

module Henson
  module API
    class GitHubClient < Client

      # Private: Initialize the tag cache on client instantiation.
      def after_initialize
        @tag_cache = {}
      end

      # Public: Fetch a list of tags for the given repository.
      #
      # repository - The String in form username/reponame on GitHub.
      # options    - The optional Hash of URL options
      #
      # Returns a Hash.
      def tags_for_repo repository, options = {}
        @tag_cache[repository] ||=
          request :get, "/repos/#{repository}/tags", options
      end

      # Public: Download a tag for a repository.
      #
      # repository  - The String in form username/reponame on GitHub.
      # tag         - The String representing the tag name.
      # destination - The String path to where the download should be saved.
      # options     - The optional Hash of URL options
      #
      # Raises Henson::GitHubDownloadError if the download fails.
      # Raises Henson::GitHubTarballNotFound if the tag is invalid.
      def download_tag_for_repo repository, tag, destination, options = {}
        tags = tags_for_repo repository

        if found = tags.detect { |t| t["name"] =~ /\Av?#{tag}\z/ }

          begin
            write_download destination,
              request(:get, found["tarball_url"], options)

          rescue Henson::APIError => e
            raise Henson::GitHubDownloadError,
              "Download of #{repository}@#{tag} failed!"
          end

        else
          raise Henson::GitHubTarballNotFound,
            "Invalid tag #{repository}@#{tag}!"
        end
      end

      private

      # Private: Write a file with some content.
      #
      # file    - The String path to the file to create or write.
      # content - The String to write into that file.
      def write_download file, content
        File.open file, "wb+" do |f|
          f.write content
        end
      end
    end
  end
end
