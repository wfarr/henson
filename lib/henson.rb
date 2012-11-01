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

  ########
  # Errors
  ########

  class Error < StandardError
    def self.exit_code(i)
      define_method(:exit_code) { i }
    end
  end

  class PuppetfileError    < Error; exit_code(14); end
  class PuppetfileNotFound < Error; exit_code(16); end
  class ModuleNotFound     < Error; exit_code(18); end
end
