require "henson/api/github_client"
require "henson/api/puppet_forge_client"

module Henson
  module API
    class ClientCache
      attr_reader :clients

      # Internal: Create a new API client cache.
      #
      # Returns self.
      def initialize
        self.tap do
          @clients = {
            :github       => {},
            :puppet_forge => {}
          }
        end
      end

      # Internal: Get the GitHub API client for the given API host.
      #
      # host - The String that is the full hostname of the API endpoint.
      #
      # Returns the Henson::API::GitHubClient.
      def github host
        clients[:github][host] ||=
          GitHubClient.new(host, :access_token => \
            (ENV["GITHUB_API_TOKEN_#{host}"] || ENV["GITHUB_API_TOKEN"])
          )
      end

      # Internal: Get the Puppet Forge API client for the given API host.
      #
      # host - The String that is the full hostname of the API endpoint.
      #
      # Returns the Henson::API::PuppetForgeClient.
      def puppet_forge host
        clients[:puppet_forge][host] ||= PuppetForgeClient.new(host)
      end
    end
  end
end
