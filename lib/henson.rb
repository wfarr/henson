require "henson/errors"
require "henson/installer"
require "henson/puppet_module"
require "henson/settings"
require "henson/version"

module Henson
  def self.settings
    @settings ||= Settings.new
  end

  def self.ui=(new_ui)
    @ui = new_ui
  end

  def self.ui
    @ui
  end
end
