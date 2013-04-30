require "henson/api_client"
require "henson/errors"
require "henson/installer"
require "henson/puppet_module"
require "henson/settings"
require "henson/version"

module Henson
  # Public: Get the active settings.
  #
  # Returns a Henson::Settings.
  def self.settings
    @settings ||= Settings.new
  end

  # Internal: Set the Henson UI.
  #
  # new_ui - The UI object.
  #
  # Returns the UI.
  def self.ui= new_ui
    @ui = new_ui
  end

  # Internal: Get the Henson UI.
  #
  # Returns the UI.
  def self.ui
    @ui
  end

  # Internal: Set the Henson GitHub API client.
  #
  # new_client - The Henson::APIClient.
  #
  # Returns the Henson::APIClient.
  def self.api_client= new_client
    @api_client = new_client
  end

  # Internal: Get the Henson API client or create one if it does not exist.
  #
  # Returns the Henson::APIClient.
  def self.api_client
    @api_client ||= Henson::APIClient.new "api.github.com",
      :access_token => ENV["GITHUB_API_TOKEN"]
  end
end
