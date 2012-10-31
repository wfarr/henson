require 'spec_helper'

describe Henson::Source::Forge do
  it "can be instantiated" do
    Henson::Source::Forge.new('foo').should_not be_nil
  end
end