require "henson/source/generic"

require "henson/source/path"

module Henson
  module Source
    def self.infer_from_opts(opts = {})
      if path = opts.delete(:path)
        Path.new path
      end
    end
  end
end