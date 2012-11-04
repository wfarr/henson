module Henson
  module Source
    class Generic
      def fetch!
        raise NotImplementedError
      end

      def versions
        raise NotImplementedError
      end

      def resolve_version_from_requirement(requirement)
        satisfiable_versions_for_requirement(requirement).sort.first
      end

      def satisfiable_versions_for_requirement(requirement)
        versions.select do |version|
          requirement.satisfied_by? Gem::Version.new(version)
        end
      end

      def satisfies?(requirement)
        satisfiable_versions_for_requirement(requirement).any?
      end

      def installed?
        File.directory? "#{Henson.settings[:path]}/#{name}"
      end
    end
  end
end
