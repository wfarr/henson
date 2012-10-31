require 'henson/friendly_errors'
require 'thor'

module Henson
  class CLI < Thor
    include Thor::Actions

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
    end
  end
end