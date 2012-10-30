$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'

require 'simplecov'

SimpleCov.start

require 'henson'

require 'rspec'
require 'mocha_standalone'
