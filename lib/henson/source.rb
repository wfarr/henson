require "henson/source/generic"

require "henson/source/file"

module Henson
  class InvalidSourceError < StandardError; end

  module Source
    def self.infer_from_opts(opts = {})
      raise Henson::InvalidSourceError unless opts.any?

      if file = opts.delete(:file)
        Henson::Source::File.new file
      end
    end
  end
end
