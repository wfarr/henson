$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'rspec'
require 'mocha_standalone'
require 'pathname'

RSpec.configure do |config|
  config.before(:suite) do
    get_your_setup_on
  end

  config.after(:suite) do
    tear_it_down
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def root
  @root ||= File.expand_path('../../', __FILE__)
end

def projectdir
  @projectdir ||= File.expand_path('./acceptance/fixtures', root)
end

def get_your_setup_on
  # wat
end

def tear_it_down
  FileUtils.rm_rf "#{projectdir}/shared"
end
