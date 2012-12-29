module Henson
  module Source
    class Git < Generic
      attr_reader :name, :repo, :options

      def initialize(name, repo, opts = {})
        @name    = name
        @repo    = repo
        @options = opts

        if branch = @options.fetch(:branch, nil)
          @target_revision = branch
          @ref_type = :branch
        elsif tag = @options.fetch(:tag, nil)
          @target_revision = tag
          @ref_type = :tag
        elsif sha = @options.fetch(:sha, nil)
          @target_revision = sha
          @ref_type = :sha
        else
          @target_revision = 'master'
          @ref_type = :branch
        end
      end

      def fetched?
        File.directory?(fetch_path) && has_ref?(target_revision)
      end

      def fetch!
        if File.directory? fetch_path
          Dir.chdir(fetch_path) do
            git 'fetch', '--quiet', 'origin'
          end
        else
          Henson.ui.debug "Fetching #{name} from #{repo}"
          git 'clone', '--quiet', repo, fetch_path
        end
      end

      def install!
        Henson.ui.debug "Changing #{name} to origin/#{target_revision}"

        Dir.chdir(fetch_path) do
          git 'checkout', '--quiet', "origin/#{target_revision}"
        end
      end

      def versions
        [ '0' ]
      end

      private
      def git(*args)
        `git #{args.join(' ')}`
      rescue Errno::ENOENT
        raise GitNotInstalled if exit_status.nil?
      end

      def has_ref?(ref)
        output = git 'cat-file', '-t', ref
        if $?.success?
          if output.strip == 'commit'
            raise GitInvalidRef, "Expected '#{ref}' in '#{name}' to be a commit."
          end
          true
        else
          false
        end
      end

      def fetch_path
        "#{Henson.settings[:path]}/#{name}"
      end

      def target_revision
         @target_revision
      end

      def ref_type
        @ref_type
      end
    end
  end
end
