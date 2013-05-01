require "henson/dsl/evaluator"

module Henson
  module DSL
    class Puppetfile < Evaluator
      attr_reader :modules

      def initialize
        @modules = []
        @forge   = nil
      end

      def mod(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        version = args.empty? ? ">= 0" : args.first

        unless options.any?
          if forge.nil?
            raise "A `forge` is required"
          else
            options.merge!(:forge => forge)
          end
        end

        PuppetModule.new(name, version, options).tap do |puppet_module|
          # TODO calculate module"s dependencies?
          @modules << puppet_module
        end
      end

      def forge(url = nil)
        if url.nil?
          @forge
        else
          @forge = url
        end
      end

      def github(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        version = args.empty? ? ">= 0" : args.first

        unless name =~ /\A.+\/.+\Z/
          raise ModulefileError, "'#{name}' is not a GitHub repository"
        end

        if options[:repo]
          options[:github] = options[:repo]
          options.delete(:repo)
        else
          options[:github] = name
        end

        module_name = name.split("/").last.gsub(/\Apuppet(labs)?-/, "")

        PuppetModule.new(module_name, version, options).tap do |puppet_module|
          @modules << puppet_module
        end
      end
    end
  end
end
