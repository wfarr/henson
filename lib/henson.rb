require "henson/api/client_cache"
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

  # Internal: Get the API client cache or create one if it does not exist.
  #
  # Returns the Henson::API::ClientCache.
  def self.api_clients
    @api_clients ||= Henson::API::ClientCache.new
  end
end
