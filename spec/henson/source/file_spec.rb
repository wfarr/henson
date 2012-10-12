require 'spec_helper'

describe Henson::Source::File do
  let(:instance) do
    Henson::Source::File.new("spec/fixtures/modules/foobar")
  end

  it "can be instantiated" do
    instance.should_not be_nil
  end

  it "is a subclass of Henson::Source::Generic" do
    instance.kind_of? Henson::Source::Generic
  end

  context "valid?" do
    it "returns true if path_exists? is true" do
      instance.stubs(:path_exists?).returns(true)
      instance.valid?.should be_true
    end

    it "returns false if path_exists? is false" do
      instance.stubs(:path_exists?).returns(false)
      instance.valid?.should be_false
    end
  end
end
