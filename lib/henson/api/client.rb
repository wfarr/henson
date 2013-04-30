require "henson/errors"
require "henson/version"

require "faraday"
require "multi_json"

module Henson
  module API
    class Client
      attr_reader :connection

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

      # Internal: Send an HTTP request via the connection.
      #
      # method  - The Symbol representing the HTTP request method.
      # path    - The String representing the path of the request.
      # options - The Hash representing either the POST body or URL params.
      #
      # Returns a Hash.
      def request method, path, options = {}
        request_options = @options.merge options

        response = connection.send method do |request|
          request.headers["User-Agent"] = "henson v#{Henson::VERSION}"

          request.url path

          case method
          when :get
            request_options.each { |k,v| request.params[k] = v unless v.nil? }
          when :post, :put
            request.body = MultiJson.dump request_options
          end
        end

        handle response, request_options
      end

      # Internal: Handle an HTTP response body as JSON.
      #
      # response - The Faraday::Response generated from the Faraday::Request.
      #
      # Returns a Hash.
      def handle response, request_options = {}
        if response.success?

          if response.body.empty?
            { "ok" => true }
          else
            MultiJson.load response.body
          end

        elsif ["301", "302"].include? response.status
          request response.env[:method],
            response.env[:location],
            request_options

        else
          raise Henson::APIError,
            "API returned #{response.status} for #{response.env[:url]} with #{request_options.inspect}"
        end
      end
    end
  end
end
