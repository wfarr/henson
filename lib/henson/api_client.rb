require "faraday"
require "henson"

module Henson
  class APIClient
    attr_reader :connection

    def initialize api_host, options = {}
      @connection = Faraday.new :url => "https://#{api_host}/"
      @options    = options
      @tag_cache  = {}
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

    private

    def request method, path, options = {}
      response = connection.send method do |request|
        request.headers["User-Agent"] = "henson v#{Henson::VERSION}"

        request.url = path

        request_options = @options.merge options

        case method
        when :get
          request_options.each { |k,v| request.params[k] = v }
        when :post, :put
          request.body = MultiJson.dump request_options
        end
      end

      handle response
    end

    def handle response
      if response.success?
        if response.body.empty?
          { "ok" => true }
        else
          MultiJson.load response.body
        end
      elsif ["301", "302"].include? response.code
        request response.env[:method], response.env[:location],
          response.env[:request_headers]
      else
        raise GitHubAPIError,
          "GitHub API returned #{response.code} for #{response.env[:url]}"
      end
    end
  end
end
