module Henson
  class DSL
    def self.evaluate(puppetfile)
      new.evaluate(puppetfile)
    end

    def evaluate(puppetfile)
      instance_eval File.read(puppetfile)
    rescue SyntaxError => e
      backtrace = e.message.split("\n")[1..-1]
      raise Henson::PuppetfileError,
        ["Puppetfile syntax error:", *backtrace].join("\n")
    end

    def mod(name, version, opts = {})
      Henson::PuppetModule.new(name, version, opts)
    end
  end
end