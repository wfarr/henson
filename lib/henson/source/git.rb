module Henson
  module Source
    class Git < Generic
      def initialize(repo, opts = {})
        @repo = repo
        @opts = opts
      end
    end
  end
end