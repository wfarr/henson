require "henson/dsl"

module Henson
  class Installer
    def self.install!
      parse_puppetfile!
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
        raise Henson::PuppetfileNotFound,
          "Expected a Puppetfile at #{Henson.settings[:puppetfile]}!"
      end
    end
  end
end
