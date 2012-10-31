require "henson/source"

module Henson
  class PuppetModule
    attr_reader :name, :version, :source

    def initialize name, version, opts = {}
      @name    = name
      @version = version
      @source  = Source.infer_from_opts opts

      if @source.nil?
        raise PuppetfileError,
          "Source given for #{@name} is invalid: #{opts.inspect}"
      end
    end
  end
end
