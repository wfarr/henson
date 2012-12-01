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
    let(:git) do
      lambda { |opts = {}|
        Henson::Source::Git.new 'osx_defaults',
          'https://github.com/wfarr/puppet-osx_defaults',
          opts
      }
    end

    it "returns branch if options branch" do
      git.(:branch => "master").send(:target_revision).should eql "master"
    end

    it "returns tag if options tag" do
      git.(:tag => "foo").send(:target_revision).should eql "foo"
    end

    it "returns ref if options ref" do
      git.(:ref => "123abc").send(:target_revision).should eql "123abc"
    end

    it "returns master otherwise" do
      git.().send(:target_revision).should eql "master"
    end
  end
end