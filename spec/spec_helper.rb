$:.unshift File.expand_path("..", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"

require "simplecov"

SimpleCov.start do
  add_filter "/vendor/gems/"
end

require "henson"

require "rspec"
require "mocha/api"

require "fakeweb"

RSpec.configure do |config|
  config.before(:all) do
    @stdout = $stdout
    @stderr = $stderr

    $stdout = File.new("spec/fixtures/stdout.log", "w+")
    $stderr = File.new("spec/fixtures/stderr.log", "w+")
  end

  config.after(:all) do
    require "fileutils"

    $stdout = @stdout
    $stderr = @stderr

    FileUtils.rm_rf("spec/fixtures/*.log")
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Henson
  def self.reset_settings
    @settings = Henson::Settings.new
  end
end
