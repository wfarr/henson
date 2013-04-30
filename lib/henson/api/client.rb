require "henson/errors"
require "henson/version"

require "faraday"
require "multi_json"

module Henson
  module API
    class Client

      # Internal: Create a new API client with an active connection
      #
      # host    - The String representing the full hostname of the API host.
      # options - The Hash of all default optional params and configuration.
      #
      # Returns self
      def initialize host, options = {}
        self.tap do
          @connection = Faraday.new :url => "https://#{host}/"
          @options    = options

          after_initialize if self.respond_to? :after_initialize
        end
      end

      protected

      # Internal: Send an HTTP request via the connection.
      #
      # method  - The Symbol representing the HTTP request method.
      # path    - The String representing the path of the request.
      # options - The Hash representing either the POST body or URL params.
      #
      # Returns a Hash.
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

      # Internal: Handle an HTTP response body as JSON.
      #
      # response - The Faraday::Response generated from the Faraday::Request.
      #
      # Returns a Hash.
      def handle response
        if response.success?

          if response.body.empty?
            { "ok" => true }
          else
            MultiJson.load response.body
          end

        elsif ["301", "302"].include? response.code
          request response.env[:method],
            response.env[:location],
            response.env[:request_headers]

        else
          raise Henson::APIError,
            "API returned #{response.code} for #{response.env[:url]}"
        end
      end
    end
  end
end
