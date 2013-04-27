require "henson/source/generic"

require "henson/source/forge"
require "henson/source/git"
require "henson/source/github_tarball"
require "henson/source/path"

module Henson
  module Source
    def self.infer_from_opts(name, requirement, opts = {})
      if path = opts.delete(:path)
        Path.new name, path
      elsif git = opts.delete(:git)
        Git.new name, git.delete(:repo), git
      elsif forge = opts.delete(:forge)
        Forge.new name, forge
      end
    end
  end
end
