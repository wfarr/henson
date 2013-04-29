require "henson/dsl/evaluator"

module Henson
  module DSL
    class Modulefile < Evaluator
      attr_reader :dependencies

      def initialize
        @name = nil
        @version = nil
        @dependencies = []
      end

      def validate
        raise VersionMissingError, @name if @version.nil?
      end

      def name(name=nil)
        if name.nil?
          @name
        else
          @name = name
        end
      end

      def version(version=nil)
        if version.nil?
          @version
        else
          @version = version
        end
      end

      def dependency(name, version=nil, repository=nil)
        @dependencies << {
          :name       => name,
          :version    => version,
          :repository => repository,
        }
      end

      def method_missing(method, *args, &block)
        ignore_methods = [
          :summary,
          :description,
          :project_page,
          :license,
          :author,
          :source,
        ]

        unless ignore_methods.include? method
          super
        end
      end
    end
  end
end
