module Henson
  module Source
    class Git < Generic
      attr_reader :name, :repo, :options

      def initialize(name, repo, opts = {})
        @name    = name
        @repo    = repo
        @options = opts

        if branch = @options.fetch(:branch, nil)
          @target_revision = "origin/#{branch}"
          @ref_type = :branch
        elsif tag = @options.fetch(:tag, nil)
          @target_revision = tag
          @ref_type = :tag
        elsif ref = @options.fetch(:ref, nil)
          @target_revision = ref
          @ref_type = :ref
        else
          @target_revision = 'origin/master'
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
        Henson.ui.debug "Changing #{name} to #{target_revision}"

        Dir.chdir(fetch_path) do
          git 'checkout', '--quiet', target_revision
        end
      end

      def installed?
        current_revision == resolved_target_revision
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
        output = ""

        Dir.chdir fetch_path do
          output = git 'cat-file', '-t', ref
        end

        output.strip!

        if $?.success?
          unless %w(commit tag).member? output
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

      def resolved_target_revision
        Dir.chdir(fetch_path) do
          output = git 'rev-parse', target_revision
          return output.strip
        end
      end

      def current_revision
        Dir.chdir(fetch_path) do
          output = git 'rev-parse', target_revision

          if $?.success?
            return output.strip
          end
        end
      end

      def ref_type
        @ref_type
      end
    end
  end
end
