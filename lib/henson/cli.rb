require 'henson/friendly_errors'
require 'thor'

module Henson
  class CLI < Thor
    include Thor::Actions

    check_unknown_options!
  end
end