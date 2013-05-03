$:.unshift File.expand_path("..", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"

require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/gems/"
end

require "henson"

require "rspec"
require "mocha/api"

require "fakeweb"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Henson
  def self.reset_settings
    Henson.unstub(:settings)
    @settings = Henson::Settings.new
  end
end
