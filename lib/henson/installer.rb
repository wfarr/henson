require "henson/dsl"
require "fileutils"

module Henson
  class Installer
    def self.install!
      FileUtils.mkdir_p File.expand_path(Henson.settings[:path])

      parse_puppetfile!.modules.each do |mod|
        mod.fetch!
        mod.install!
      end
    end

    def self.local!
      Henson.settings[:local] = true
    end

    def self.no_cache!
      Henson.settings[:no_cache] = true
    end

    def self.clean!
      Henson.settings[:clean] = true
    end

    def self.parse_puppetfile!
      unless File.exists?(Henson.settings[:puppetfile])
        raise PuppetfileNotFound,
          "Expected a Puppetfile at #{Henson.settings[:puppetfile]}!"
      end

      DSL::Puppetfile.evaluate(Henson.settings[:puppetfile])
    end
  end
end
