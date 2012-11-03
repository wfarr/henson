require "henson/source"

module Henson
  class PuppetModule
    attr_reader :name, :version, :source, :requirement

    def initialize name, version, opts = {}
      @name    = name
      @version = version
      @source  = Source.infer_from_opts opts
      @requirement = Gem::Requirement.new(version)

      if @source.nil?
        raise PuppetfileError,
          "Source given for #{@name} is invalid: #{opts.inspect}"
      end
    end

    def satisfied?
      source.satisfies? @requirement
    end

    def fetch!
      source.fetch!
    end
  end
end
