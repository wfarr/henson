require 'henson/friendly_errors'
require 'thor'

module Henson
  class CLI < Thor
    include Thor::Actions
  end
end