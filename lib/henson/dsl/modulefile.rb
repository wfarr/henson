module Henson
  class DSL
    class Modulefile
      attr_reader :dependencies

      def self.evaluate(modulefile)
        new.evaluate(modulefile)
      end

      def initialize
        @name = nil
        @version = nil
        @dependencies = []
      end

      def evaluate(modulefile)
        raise ModulefileNotFound unless File.exists?(modulefile)

        instance_eval File.read(modulefile)

        raise VersionMissingError, @name if @version.nil?

        self
      rescue SyntaxError => e
        backtrace = e.message.split("\n")[1..-1]
        raise ModulefileError,
          ["Modulefile syntax error:", *backtrace].join("\n")
      rescue ScriptError, RegexpError, NameError, ArgumentError => e
        e.backtrace[0] = "#{e.backtrace[0]}: #{e.message} (#{e.class})"
        Henson.ui.warning e.backtrace.join("\n       ")
        raise ModulefileError,
          "There was an error parsing #{modulefile}, Henson can not continue."
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
