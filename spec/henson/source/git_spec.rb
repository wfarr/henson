require 'spec_helper'

describe Henson::Source::Git do
  it "can be instantiated" do
    Henson::Source::Git.new('foo', :bar => :baz).should_not be_nil
  end

  describe "#fetched?" do
    it "returns false if the repo is not cloned"
    it "returns false if the repo does not have the correct revision"
    it "returns true if cloned and the correct revision"
  end

  describe "#fetch!" do
    it "clones the repository and checks out the revision"
  end

  describe "#install!" do
    it "moves the repository tracked files from the tmp path to install path"
    it "logs an info level install message"
    it "logs a debug level install message"
  end

  describe "#versions" do
    it "returns the target revision as the only version available"
  end

  describe "#valid?" do
    it "returns true if the repo can be cloned"
    it "returns false if the repo cannot be cloned"
    it "returns false if the revision does not exist"
  end

  describe "#target_revision" do
    it "returns branch if options branch"
    it "returns tag if options tag"
    it "returns ref if options ref"
    it "returns master otherwise"
  end
end