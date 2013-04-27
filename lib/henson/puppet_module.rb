require "henson/source"

module Henson
  class PuppetModule
    attr_reader :name, :version, :source, :requirement

    def initialize(name, version_requirement, opts = {})
      @name        = name
      @requirement = Gem::Requirement.new(version_requirement)
      @source      = Source.infer_from_opts name, requirement, opts

      if @source.nil?
        raise PuppetfileError,
          "Source given for #{@name} is invalid: #{opts.inspect}"
      end

      @version = @source.resolve_version_from_requirement(@requirement)
    end

    def fetched?
      source.fetched?
    end

    def installed?
      source.installed?
    end

    def satisfied?
      source.satisfies? requirement
    end

    def needs_fetching?
      !fetched?
    end

    def needs_installing?
      !satisfied? || !installed?
    end

    def fetch!
      source.fetch!
    end

    def install!
      source.install!
    end

    def versions
      source.versions
    end
  end
end
