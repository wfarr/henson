module Henson
  class DSL
    class Puppetfile
      attr_reader :modules

      def self.evaluate(puppetfile)
        new.evaluate(puppetfile)
      end

      def initialize
        @modules = []
        @forge   = nil
      end

      def evaluate(puppetfile)
        instance_eval File.read(puppetfile)
        self
      rescue SyntaxError => e
        backtrace = e.message.split("\n")[1..-1]
        raise PuppetfileError,
          ["Puppetfile syntax error:", *backtrace].join("\n")
       rescue ScriptError, RegexpError, NameError, ArgumentError => e
         e.backtrace[0] = "#{e.backtrace[0]}: #{e.message} (#{e.class})"
         Henson.ui.warning e.backtrace.join("\n       ")
         raise PuppetfileError,
           "There was an error in your Puppetfile, and Henson cannot continue."
      end

      def mod(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        version = args.empty? ? ">= 0" : args.first

        unless options.any?
          if forge.nil?
            # TODO - Implicit forge URL or throw error?
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
