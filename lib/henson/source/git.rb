module Henson
  module Source
    class Git < Generic
      def initialize(repo, options = {})
        @repo = repo
        @options = options
      end

      private
      def target_revision
         @target_revision ||= if branch = @options.delete(:branch)
                                branch
                              elsif tag = @options.delete(:tag)
                                tag
                              elsif ref = @options.delete(:ref)
                                ref
                              else
                                'master'
                              end
      end
    end
  end
end