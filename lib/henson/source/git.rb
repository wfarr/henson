module Henson
  module Source
    class Git < Generic
      class Revision
        LENGTH = 7

        def initialize(sha)
          @sha = sha
        end

        def to_s
          @sha.slice(0, 7)
        end

        def ==(other)
          raise "not a revision" unless other.is_a? Revision
          self.to_s == other.to_s
        end
      end

      attr_reader :name, :repo, :options

      def initialize(name, repo, opts = {})
        @name    = name
        @repo    = repo
        @options = opts


        # if it's a branch, all possible versions are refs on that branch

        # check if branch is a branch with git ls-remote --heads --exit-code origin

        # list of refs we can use if updating
        # git log --oneline --topo-order current_revision~1..target_revision

        # if new branch, but new branch contains current_revision, we're okay

        # if new branch, but does not contain current_revision, set #versions to just ref of target_revision
        if branch = @options.fetch(:branch, nil)
          @target_revision = "origin/#{branch}"
          @ref_type = :branch
        elsif tag = @options.fetch(:tag, nil)
          @target_revision = tag
          @ref_type = :tag

        elsif ref = @options.fetch(:ref, nil)
          @target_revision = Revision.new(ref)
          @ref_type = :ref
        else
          @target_revision = 'origin/master'
          @ref_type = :branch
        end
      end

      def fetched?
        File.directory?(fetch_path)
      end

      def fetch!
        if File.directory? fetch_path
          in_repo do
            git 'fetch', '--force', '--quiet', '--tags', 'origin', '"refs/heads/*:refs/heads/*"'
          end
        else
          Henson.ui.debug "Fetching #{name} from #{repo}"

          clone_args = %w(--no-hardlinks)
          clone_args << '--quiet' if Henson.settings[:quiet]

          git 'clone', *clone_args, repo, fetch_path
        end
      end

      def install!
        Henson.ui.debug "Changing #{name} to #{target_revision}"

        in_repo do
          git 'checkout', '--quiet', target_revision
        end
      end

      def installed?
        current_revision == resolved_target_revision
      end

      def versions
        @versions ||= case @ref_type
        when :ref
          in_repo do
            git('rev-list', '--all').split("\n").map { |r| Revision.new(r).to_s }
          end
        when :tag
          in_repo do
            git('ls-remote', '--exit-code', '--tags', 'origin').split("\n").map do |line|
              tag = line.match(/\s+refs\/tags\/(.+)$/)[1]
            end.reject do |tag|
              tag =~ /\^{}/
            end
          end
        when :branch
          in_repo do
            git(%w(ls-remote --exit-code --heads origin)).split("\n").map do |line|
              branch = line.match(/\s+refs\/heads\/(.+)$/)[1]
            end
          end
        else
          raise "not really possible"
        end
      end

      # overrides
      def resolve_version_from_requirement(requirement)
        satisfiable_versions_for_requirement(requirement).sort.first
      end

      def satisfiable_versions_for_requirement(requirement)
        fetch! unless fetched?

        if @ref_type == :tag || @ref_type == :branch
          versions.select { |v| v =~ Regexp.new(target_revision.gsub(/^origin\//, '')) }
        else
          sanitized_versions = versions.map { |v| v.gsub(/^origin\//, '') }
        end
      end

      def satisfies?(requirement)
        if @ref_type == :tag || @ref_type == :branch
          versions.member? target_revision.gsub(/^origin\//, '').to_s
        else
          versions.member? resolved_target_revision.to_s
        end
      end

      private
      def git(*args)
        `git #{args.join(' ')}`
      rescue Errno::ENOENT
        raise GitNotInstalled if exit_status.nil?
      end

      def in_repo
        raise "wtf" unless block_given?

        Dir.chdir fetch_path do
          yield
        end
      end

      def has_ref?(ref)
        output = in_repo do
          git('cat-file', '-t', ref).strip
        end

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
        in_repo do
          Revision.new(git('rev-parse', "#{target_revision}^{commit}").strip)
        end
      end

      def current_revision
        in_repo do
          if rev = git('rev-parse', 'HEAD').strip
            raise "wtf" unless $?.success?
            Revision.new(rev)
          end
        end
      end

      def ref_type
        @ref_type
      end
    end
  end
end
