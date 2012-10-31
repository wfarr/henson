module Henson
  class Installer
    def self.install!
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
  end
end