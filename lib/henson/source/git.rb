module Henson
  module Source
    class Git < Generic
      attr_reader :name, :repo, :options

      def initialize(name, repo, opts = {})
        @name    = name
        @repo    = repo
        @options = opts
      end

      def fetched?
        false
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

      def fetch_path
        "#{Henson.settings[:path]}/#{name}"
      end

      def target_revision
         @target_revision ||= if branch = options.delete(:branch)
                                branch
                              elsif tag = options.delete(:tag)
                                tag
                              elsif ref = options.delete(:ref)
                                ref
                              else
                                'master'
                              end
      end
    end
  end
end