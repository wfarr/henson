require 'spec_helper'

describe Henson::DSL do
  context "self.evaluate" do
    let(:instance) { Henson::DSL.new }
    it "creates a new instance and calls evaluate" do
      Henson::DSL.expects(:initialize).returns(instance)
      instance.expects(:evaluate).with('foobar')
      Henson::DSL.evaluate('foobar')
    end
  end

  context "evaluate" do
    it "is defined" do
      lambda {
        Henson::DSL.new.evaluate('foobar')
      }.should_not raise_error(NoMethodError)
    end
  end
end