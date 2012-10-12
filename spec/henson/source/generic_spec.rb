require 'spec_helper'

describe Henson::Source::Generic do
  let(:instance) { Henson::Source::Generic.new }

  it "can be instantiated" do
    instance.should_not be_nil
  end
end
