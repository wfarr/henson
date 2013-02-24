$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'rspec'
require 'mocha_standalone'

RSpec.configure do |config|
  config.before(:suite) do
    get_your_setup_on
  end

  config.after(:suite) do
    tear_that_shit_down
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

def tear_that_shit_down
  FileUtils.rm_rf "#{projectdir}/shared"
end
