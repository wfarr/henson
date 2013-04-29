require "henson/dsl"
require "fileutils"

module Henson
  class Installer
    def self.install!
      FileUtils.mkdir_p File.expand_path(Henson.settings[:path])

      parse_puppetfile!.modules.each do |mod|
        mod.fetch! if mod.needs_fetching?

        if mod.needs_installing?
          mod.install!
        else
          install_path = "#{Henson.settings[:path]}/#{mod.name}"
          Henson.ui.debug "Using #{mod.name} (#{mod.version}) from #{install_path} as #{mod.source.class.name.split("::").last.downcase}"
          Henson.ui.info  "Using #{mod.name} (#{mod.version})"
        end
      end

      Henson.ui.success "Your modules are ready to use!"
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
