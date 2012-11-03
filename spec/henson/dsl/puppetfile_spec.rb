require 'spec_helper'

describe Henson::DSL::Puppetfile do
  let(:instance) { described_class.new }

  context "self.evaluate" do
    it "creates a new instance and calls evaluate" do
      described_class.expects(:initialize).returns(instance)
      instance.expects(:evaluate).with('spec/fixtures/Puppetfile')
      described_class.evaluate('spec/fixtures/Puppetfile')
    end
  end

  context "#evaluate" do
    it "raises PuppetfileError if a syntax error is encountered" do
      lambda {
        described_class.evaluate('spec/fixtures/Puppetfile.with_syntax_error')
      }.should raise_error(
        Henson::PuppetfileError,
        /Puppetfile syntax error:/
      )
    end

    it "raises PuppetfileError if a ScriptError is encountered" do
      lambda {
        described_class.evaluate('spec/fixtures/Puppetfile.with_script_error')
      }.should raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if a RegexpError is encountered" do
      lambda {
        described_class.evaluate('spec/fixtures/Puppetfile.with_regexp_error')
      }.should raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if a NameError is encountered" do
      lambda {
        described_class.evaluate('spec/fixtures/Puppetfile.with_name_error')
      }.should raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if an ArgumentError is encountered" do
      lambda {
        described_class.evaluate('spec/fixtures/Puppetfile.with_argument_error')
      }.should raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end
  end

  context "#mod" do
    let(:path) { 'spec/fixtures/modules/foobar' }
    let(:mod) { instance.mod('foobar', '0', :path => path) }

    it "returns a PuppetModule" do
      mod.should be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      instance.modules.should be_empty
      mod
      instance.modules.should eql [mod]
    end

    it "defaults the version to '>= 0' if none given" do
      instance.mod('foobar', :path => path).version.should eql ">= 0"
    end

    it "sets the forge option if options is empty and forge is set" do
      instance.stubs(:forge).returns("http://forge.puppetlabs.com")
      instance.mod('foobar').source.should be_a Henson::Source::Forge
    end
  end

  context "#forge" do
    it "returns the url with no args" do
      instance.instance_variable_set("@forge", "lolerskates")
      instance.forge.should eql "lolerskates"
    end

    it "sets the url if given an arg" do
      instance.instance_variable_get("@forge").should be_nil
      instance.forge("foobar")
      instance.instance_variable_get("@forge").should eql "foobar"
    end
  end
end
