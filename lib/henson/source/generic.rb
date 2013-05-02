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
        satisfiable_versions_for_requirement(requirement).sort.reverse.first
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

      private

      # Internal: Extract a tarball to a specified destination, stripping the
      # first component from the paths in the tarball. Utilized by Forge and
      # GitHubTarball sources only.
      #
      # tarball - The String path on disk to the tarball.
      # dest    - The String path on disk to the directory that the tarball
      #           will be extracted into.
      #
      # Returns nothing.
      def extract_tarball(tarball, dest)
        Henson.ui.debug "Extracting #{tarball} to #{dest}"

        Gem::Package::TarReader.new(Zlib::GzipReader.open(tarball)).each do |entry|
          entry_name = entry.full_name.split("/")[1..-1].join("/")

          if entry.file?
            File.open("#{dest}/#{entry_name}", "wb") { |f| f.write entry.read }
          elsif entry.directory?
            FileUtils.mkdir_p "#{dest}/#{entry_name}"
          end
        end
      end
    end
  end
end
