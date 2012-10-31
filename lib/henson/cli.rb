require 'henson/ui'
require 'henson/friendly_errors'
require 'thor'

module Henson
  class CLI < Thor
    include Thor::Actions

    def initialize(*)
      super
      the_shell = options["no-color"] ? Thor::Shell::Basic.new : shell
      Henson.ui = UI.new the_shell
      Henson.ui.quiet! if options["quiet"]
      Henson.ui.debug! if options["verbose"]
      if ENV['HENSON_PUPPETFILE']
        Henson.settings[:puppetfile] = ENV['HENSON_PUPPETFILE']
      end
    end

    check_unknown_options!

    default_task :install

    desc "install", "Install the current Puppet module environment"
    long_desc <<-D
      Install will install all of the Puppet modules in the current
      configuration, making them available for use as long as your modulepath
      is configured correctly.
    D
    method_option "quiet", :type => :boolean, :banner =>
      "Only output warnings and errors."
    method_option "local", :type => :boolean, :banner =>
      "Only check local cache source for modules."
    method_option "no-cache", :type => :boolean, :banner =>
      "Don't update the existing Puppet module cache."
    method_option "clean", :type => :boolean, :banner =>
      "Run henson clean automatically after install."
    def install
      Installer.local! if options[:local]
      Installer.no_cache! if options[:"no-cache"]
      Installer.clean! if options[:clean]

      Installer.install!
    end
  end
end