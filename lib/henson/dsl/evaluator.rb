require "henson/errors"

module Henson
  module DSL
    class Evaluator
      def self.evaluate file
        new.evaluate file
      end

      def evaluate file
        self.tap do
          if File.exists? file
            instance_eval File.read(file)
            validate if self.respond_to? :validate
          else
            raise not_found_error_class, "#{file} does not exist"
          end
        end

      rescue SyntaxError => e
        backtrace = e.message.split("\n")[1..-1]
        raise syntax_error_class, [
            "Henson encountered a syntax error in '#{file}':",
            *backtrace
          ].join("\n")

      rescue ScriptError, RegexpError, NameError, ArgumentError => e
        e.backtrace[0] = "#{e.backtrace[0]}: #{e.message} (#{e.class})"
        Henson.ui.warning e.backtrace.join("\n       ")

        raise syntax_error_class,
          "Henson encountered an error in '#{file}' and cannot continue."
      end

      def syntax_error_class
        classify "#{self.class.name.rpartition('::').last}Error"
      end

      def not_found_error_class
        classify "#{self.class.name.rpartition('::').last}NotFound"
      end

      private
      def classify klass
        if Henson.const_defined? klass
          Henson.const_get klass
        else
          raise "invalid class name"
        end
      end
    end
  end
end
