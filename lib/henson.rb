require "henson/api_client"
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

  def self.api_client
    @api_client ||= Henson::APIClient.new "api.github.com",
      :access_token => ENV["GITHUB_API_TOKEN"]
  end
end
