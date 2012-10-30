require "henson/source"

module Henson
  class PuppetModule
    attr_reader :name, :version, :source

    def initialize name, version, opts = {}
      @name    = name
      @version = version
      @source  = Henson::Source.infer_from_opts opts

      if @source.nil?
        abort "Invalid source for #{@name}"
      end
    end
  end
end