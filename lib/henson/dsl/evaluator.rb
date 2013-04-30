require "henson/errors"

module Henson
  module DSL
    class Evaluator
      # Public: Evaluate a file with the given DSL.
      #
      # file - The String path to the file to evaluate.
      #
      # Returns an instance of the DSL.
      def self.evaluate file
        new.evaluate file
      end

      # Public: Evaluate a file with the given DSL.
      #
      # file - The String path to the file to evaluate.
      #
      # Returns an instance of the DSL.
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

      private

      # Private: Construct the class name for syntax errors during evaluation.
      #
      # Returns the Class.
      def syntax_error_class
        classify "#{short_class_name}Error"
      end

      # Private: Construct the class name forwhen  the file to parse is
      #          not found.
      #
      # Returns the Class.
      def not_found_error_class
        classify "#{short_class_name}NotFound"
      end

      # Private: Grab the last segment of the full class name for this class.
      #
      # Returns a String.
      def short_class_name
        @short_class_name ||= self.class.name.rpartition("::").last
      end

      # Private: Converts a string into a Henson error class if one exists.
      #
      # klass - The String representing the class name under Henson.
      #
      # Returns the Class.
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
