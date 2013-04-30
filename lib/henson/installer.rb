require "henson/dsl"
require "fileutils"

module Henson
  class Installer
    # Public: Install all modules declared in the settings' Puppetfile.
    def self.install!
      FileUtils.mkdir_p File.expand_path(Henson.settings[:path])

      evaluate_puppetfile! Henson.settings[:puppetfile]

      Henson.ui.success "Your modules are ready to use!"
    end

    # Internal: Force Henson to run in local-mode.
    def self.local!
      Henson.settings[:local] = true
    end

    # Internal: Force Henson to run in no-cache-mode.
    def self.no_cache!
      Henson.settings[:no_cache] = true
    end

    # Internal: Force Henson to run in clean-mode.
    def self.clean!
      Henson.settings[:clean] = true
    end

    # Internal: Evaluate a Puppetfile and install its modules.
    #
    # file - The String path to the file.
    #
    # Returns an Array of PuppetModule instances.
    def self.evaluate_puppetfile! file
      DSL::Puppetfile.evaluate(file).modules.each do |mod|
        fetch_module! mod
        install_module! mod
      end
    end

    # Internal: Fetch a module if it needs fetching.
    #
    # mod - The PuppetModule to fetch.
    def self.fetch_module! mod
      if mod.needs_fetching?
        mod.fetch!
      else
        Henson.ui.debug "#{mod} does not need fetching"
      end
    end

    # Internal: Install a module if it needs installing.
    #
    # mod - The PuppetModule to install.
    def self.install_module! mod
      if mod.needs_installing?
        mod.install!
      else
        install_path = "#{Henson.settings[:path]}/#{mod.name}"
        Henson.ui.debug "Using #{mod.name} (#{mod.version}) from #{install_path} as #{mod.source_name}"
        Henson.ui.info  "Using #{mod.name} (#{mod.version})"
      end
    end
  end
end
