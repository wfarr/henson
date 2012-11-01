require "henson/source"

module Henson
  class PuppetModule
    attr_reader :name, :version, :source

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
      source.versions.each do |version_str|
        return true if @requirement.satisfied_by? Gem::Version.new(version_str)
      end
      false
    end
  end
end
