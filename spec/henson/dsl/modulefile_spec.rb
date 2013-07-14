require "spec_helper"

describe Henson::DSL::Modulefile do
  subject(:it) { described_class.new }
  let(:ui)     { double("UI") }

  before do
    Henson.stubs(:ui).returns(ui)
  end

  after do
    Henson.unstub(:ui)
  end

  describe "#evaluate" do
    before do
      ui.expects(:warning)
    end

    it "raises ModulefileError if a syntax error is encountered" do
      file = "spec/fixtures/Modulefile.with_syntax_error"

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /Henson encountered a syntax error in '#{file}':/
      )
    end

    it "raises ModulefileError if a ScriptError is encountered" do
      file = "spec/fixtures/Modulefile.with_script_error"

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises ModulefileError if a RegexpError is encountered" do
      file = "spec/fixtures/Modulefile.with_regexp_error"

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises ModulefileError if a NameError is encountered" do
      file = "spec/fixtures/Modulefile.with_name_error"

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises ModulefileError if an ArgumentError is encountered" do
      file = "spec/fixtures/Modulefile.with_argument_error"

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /Henson encountered an error in '#{file}' and cannot continue\./
      )
    end

    it "raises VersionMissingError if no version declared" do
      file = "spec/fixtures/Modulefile.without_version"

      expect {
        described_class.evaluate(file)
      }.to raise_error(Henson::VersionMissingError, "foobar")
    end
  end

  describe "#name" do
    it "should store the module name when passed an arg" do
      it.name("test")
      expect(it.instance_variable_get(:@name)).to eq("test")
    end

    it "should retrieve the module name when passed no args" do
      expect(it.name).to be_nil
      it.name("test2")
      expect(it.name).to eq("test2")
    end
  end

  describe "#version" do
    it "should store the module version when passed an arg" do
      it.version("0.0.0")
      expect(it.instance_variable_get(:@version)).to eq("0.0.0")
    end

    it "should retrieve the module name when passed no args" do
      expect(it.version).to be_nil
      it.version("0.0.1")
      expect(it.version).to eq("0.0.1")
    end
  end

  describe "#dependency" do
    it "should store the dependency name when passed one arg" do
      it.dependency("foo")
      expect(it.instance_variable_get(:@dependencies)).to eq([
        {:name => "foo", :version => nil, :repository => nil}
      ])
    end

    it "should store the dependency version when passed two args" do
      it.dependency("bar", "1.2.3")
      expect(it.instance_variable_get(:@dependencies)).to eq([
        {:name => "bar", :version => "1.2.3", :repository => nil}
      ])
    end

    it "should store the dependency repository when passed two args" do
      it.dependency("bar", "1.2.3", "something")
      expect(it.instance_variable_get(:@dependencies)).to eq([
        {:name => "bar", :version => "1.2.3", :repository => "something"}
      ])
    end

    it "should be able to store multiple dependencies" do
      it.dependency("foo")
      it.dependency("bar")
      expect(it.instance_variable_get(:@dependencies)).to eq([
        {:name => "foo", :version => nil, :repository => nil},
        {:name => "bar", :version => nil, :repository => nil},
      ])
    end
  end

  describe "#dependencies" do
    it "should be able to retrieve the stored dependencies" do
      expect(it.dependencies).to be_empty

      it.dependency("foo")

      expect(it.dependencies).to eq([
        {:name => "foo", :version => nil, :repository => nil}
      ])
    end
  end

  %w(summary description project_page license author source).each do |f|
    describe "##{f}" do
      it "should not throw a parse error" do
        expect { it.send(f, "foo") }.to_not raise_error
      end
    end
  end

  describe "an unknown method" do
    it "should raise a parse error" do
      expect { it.foobarbaz("foo") }.to raise_error
    end
  end
end
