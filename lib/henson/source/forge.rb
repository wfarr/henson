module Henson
  module Source
    class Forge < Generic
      def initialize(name, forge)
        @forge = forge
      end

      def fetched?;   end
      def installed?; end

      def versions; []; end

      def fetch!
        # TODO implement me
      end

      def install!
        # TODO implement me
      end
    end
  end
end
