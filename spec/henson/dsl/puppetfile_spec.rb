require "spec_helper"

describe Henson::DSL::Puppetfile do
  subject(:it) { described_class.new }
  let(:ui)     { double("UI") }

  before do
    Henson.stubs(:ui).returns(ui)

    ui.expects(:warning)
  end

  after do
    Henson.unstub(:ui)
  end

  context "#evaluate" do
    it "raises PuppetfileError if a syntax error is encountered" do
      file = "spec/fixtures/Puppetfile.with_syntax_error"

      expect { described_class.evaluate file }.to raise_error(
        Henson::PuppetfileError,
        /Henson encountered a syntax error in '#{file}':/
      )
    end

    it "raises PuppetfileError if a ScriptError is encountered" do
      file = "spec/fixtures/Puppetfile.with_script_error"

      expect { described_class.evaluate file }.to raise_error(
        Henson::PuppetfileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises PuppetfileError if a RegexpError is encountered" do
      file = "spec/fixtures/Puppetfile.with_regexp_error"

      expect { described_class.evaluate file }.to raise_error(
        Henson::PuppetfileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises PuppetfileError if a NameError is encountered" do
      file = "spec/fixtures/Puppetfile.with_name_error"

      expect { described_class.evaluate file }.to raise_error(
        Henson::PuppetfileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises PuppetfileError if an ArgumentError is encountered" do
      file = "spec/fixtures/Puppetfile.with_argument_error"

      expect { described_class.evaluate file }.to raise_error(
        Henson::PuppetfileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end
  end

  context "#mod" do
    let(:path) { "spec/fixtures/modules/foobar" }
    let(:mod) { it.mod("foobar", "0", :path => path) }

    it "returns a PuppetModule" do
      expect(mod).to be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      expect(it.modules).to be_empty
      mod
      expect(it.modules).to eq([mod])
    end

    it "sets the forge option if options is empty and forge is set" do
      it.stubs(:forge).returns("https://forge.puppetlabs.com/")
      expect(it.mod("wfarr/osx_defaults").source).to be_a(Henson::Source::Forge)
    end

    it "should not require a version number" do
      expect(it.mod("foobar", :path => path).requirement).to eq(Gem::Requirement.new(">= 0"))
    end
  end

  context "#forge" do
    it "returns the url with no args" do
      it.instance_variable_set("@forge", "lolerskates")
      expect(it.forge).to eq("lolerskates")
    end

    it "sets the url if given an arg" do
      expect(it.instance_variable_get("@forge")).to be_nil
      it.forge("foobar")
      expect(it.instance_variable_get("@forge")).to eq("foobar")
    end
  end

  context "#github" do
    let(:mod) { it.github("puppetlabs/puppetlabs-stdlib", "~> 1") }

    before do
      FakeWeb.register_uri(
        :get, "https://api.github.com/repos/puppetlabs/puppetlabs-stdlib/tags",
        :body => MultiJson.dump([{:name => "1.0.0"}]),
      )
    end

    after do
      FakeWeb.clean_registry
    end

    it "returns a PuppetModule" do
      expect(mod).to be_a Henson::PuppetModule
    end

    it "adds the module to the modules array" do
      expect(it.modules).to be_empty
      mod
      expect(it.modules).to eq([mod])
    end

    it "should create a module of with a GitHub source" do
      expect(mod.source).to be_a(Henson::Source::GitHub)
    end

    it "should not require a version number" do
      expect(it.github("puppetlabs/puppetlabs-stdlib").requirement).to eq(Gem::Requirement.new(">= 0"))
    end

    it "should raise an error if not passed a GitHub repository" do
      expect { it.github("puppetlabs-stdlib") }.to raise_error(
        Henson::ModulefileError, "'puppetlabs-stdlib' is not a GitHub repository"
      )
    end
  end
end
