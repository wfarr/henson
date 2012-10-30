require 'spec_helper'

describe Henson::PuppetModule do
  let(:mod) { Henson::PuppetModule.new 'example', '0', :file => "/foo/bar/baz" }

  it "must have a source" do
    mod.source.should_not be_nil
  end
end