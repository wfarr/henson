module Henson
  class DSL
    attr_reader :modules

    def self.evaluate(puppetfile)
      new.evaluate(puppetfile)
    end

    def initialize
      @modules = []
    end

    def evaluate(puppetfile)
      instance_eval File.read(puppetfile)
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

    def mod(name, version, opts = {})
      PuppetModule.new(name, version, opts).tap do |puppet_module|
        puppet_module.fetch! unless puppet_module.source.kind_of? Source::Path

        @modules << puppet_module
      end
    end
  end
end