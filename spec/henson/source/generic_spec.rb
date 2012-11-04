require 'spec_helper'

describe Henson::Source::Generic do
  let(:source) { Henson::Source::Generic.new }

  it "can be instantiated" do
    source.should_not be_nil
  end

  it "requires subclasses implement fetch!" do
    lambda {
      source.fetch!
    }.should raise_error(NotImplementedError)
  end

  it "requires subclasses implement versions" do
    lambda {
      source.versions
    }.should raise_error(NotImplementedError)
  end

  context "satisfies?" do
    let(:requirement) { Gem::Requirement.new '~> 1.0.0' }

    it "returns true if any version satisfies the requirement" do
      source.stubs(:versions).returns(['0.8', '1.0.11'])
      source.satisfies?(requirement).should be_true
    end

    it "returns false if no version satisfies the requirement" do
      source.stubs(:versions).returns(['0.8', '1.6.0'])
      source.satisfies?(requirement).should be_false
    end
  end
end