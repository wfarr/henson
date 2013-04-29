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
      expect {
        described_class.evaluate('spec/fixtures/Puppetfile.with_syntax_error')
      }.to raise_error(
        Henson::PuppetfileError,
        /Puppetfile syntax error:/
      )
    end

    it "raises PuppetfileError if a ScriptError is encountered" do
      expect {
        described_class.evaluate('spec/fixtures/Puppetfile.with_script_error')
      }.to raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if a RegexpError is encountered" do
      expect {
        described_class.evaluate('spec/fixtures/Puppetfile.with_regexp_error')
      }.to raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if a NameError is encountered" do
      expect {
        described_class.evaluate('spec/fixtures/Puppetfile.with_name_error')
      }.to raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end

    it "raises PuppetfileError if an ArgumentError is encountered" do
      expect {
        described_class.evaluate('spec/fixtures/Puppetfile.with_argument_error')
      }.to raise_error(
        Henson::PuppetfileError,
        /There was an error in your Puppetfile, and Henson cannot continue\./
      )
    end
  end

  context "#mod" do
    let(:path) { 'spec/fixtures/modules/foobar' }
    let(:mod) { instance.mod('foobar', '0', :path => path) }

    it "returns a PuppetModule" do
      expect(mod).to be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      expect(instance.modules).to be_empty
      mod
      expect(instance.modules).to eq([mod])
    end

    it "sets the forge option if options is empty and forge is set" do
      instance.stubs(:forge).returns("http://forge.puppetlabs.com")
      expect(instance.mod('foobar').source).to be_a(Henson::Source::Forge)
    end

    it "should not require a version number" do
      expect(instance.mod('foobar', :path => path).requirement).to eq(Gem::Requirement.new('>= 0'))
    end
  end

  context "#forge" do
    it "returns the url with no args" do
      instance.instance_variable_set("@forge", "lolerskates")
      expect(instance.forge).to eq("lolerskates")
    end

    it "sets the url if given an arg" do
      expect(instance.instance_variable_get("@forge")).to be_nil
      instance.forge("foobar")
      expect(instance.instance_variable_get("@forge")).to eq("foobar")
    end
  end

  context "#github" do
    let(:mod) { instance.github('puppetlabs/puppetlabs-stdlib', '~> 1') }

    before do
      FakeWeb.register_uri(
        :get, "https://api.github.com/repos/puppetlabs/puppetlabs-stdlib/tags",
        :body => [{:name => '1.0.0'}].to_json,
      )
    end

    after do
      FakeWeb.clean_registry
    end

    it "returns a PuppetModule" do
      expect(mod).to be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      expect(instance.modules).to be_empty
      mod
      expect(instance.modules).to eq([mod])
    end

    it "should create a module of with a GitHubTarball source" do
      expect(mod.source).to be_a(Henson::Source::GitHubTarball)
    end

    it "should not require a version number" do
      expect(instance.github('puppetlabs/puppetlabs-stdlib').requirement).to eq(Gem::Requirement.new('>= 0'))
    end

    it "should raise an error if not passed a GitHub repository" do
      expect { instance.github('puppetlabs-stdlib') }.to raise_error(
        Henson::ModulefileError, "'puppetlabs-stdlib' is not a GitHub repository"
      )
    end
  end
end
