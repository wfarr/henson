require "henson/installer"
require "henson/puppet_module"
require "henson/settings"
require "henson/version"

module Henson
  def self.settings
    @settings ||= Henson::Settings.new
  end
end
