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

  context "evaluate" do
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

  context "mod" do
    let(:path) { 'spec/fixtures/modules/foobar' }
    let(:mod) { instance.mod('foobar', '0', :path => path) }

    it "returns a PuppetModule" do
      mod.should be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      instance.modules.should be_empty
      mod
      instance.modules.should include(mod)
    end

    context "when source is a Path" do
      it "does not call fetch! on the module" do
        Henson::PuppetModule.any_instance.expects(:fetch!).never
        instance.mod('foobar', '0', :path => path)
      end
    end

    context "when source is not a Path" do
      it "calls fetch! on the module" do
        Henson::PuppetModule.expects(:fetch!).once
        instance.mod('foobar', '0', :forge => 'wfarr/whatever')
      end
    end
  end
end
