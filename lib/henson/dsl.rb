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
    end
  end
end