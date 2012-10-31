require "henson/source/generic"

require "henson/source/forge"
require "henson/source/path"

module Henson
  module Source
    def self.infer_from_opts(opts = {})
      if path = opts.delete(:path)
        Path.new path
      elsif forge = opts.delete(:forge)
        Forge.new forge
      end
    end
  end
end