module Henson
  module Source
    class GitHubTarball < Generic
      def initialize(repo)
        @repo = repo
      end
    end
  end
end