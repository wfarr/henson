require 'spec_helper'

describe Henson::Source::Git do
  it "can be instantiated" do
    Henson::Source::Git.new('foo', :bar => :baz).should_not be_nil
  end
end