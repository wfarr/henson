module Henson
  module Source
    class Generic
      def fetch!
        raise NotImplementedError
      end

      def versions
        raise NotImplementedError
      end

      def satisfies?(requirement)
        versions.any? do |version|
          requirement.satisfied_by? Gem::Version.new(version)
        end
      end
    end
  end
end
