require "spec_helper"

describe Henson::DSL::Modulefile do
  let(:instance) { described_class.new }

  context "#evaluate" do
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

  context "#name" do
    it "should store the module name when passed an arg" do
      instance.name("test")
      expect(instance.instance_variable_get(:@name)).to eq("test")
    end

    it "should retrieve the module name when passed no args" do
      expect(instance.name).to be_nil
      instance.name("test2")
      expect(instance.name).to eq("test2")
    end
  end

  context "#version" do
    it "should store the module version when passed an arg" do
      instance.version("0.0.0")
      expect(instance.instance_variable_get(:@version)).to eq("0.0.0")
    end

    it "should retrieve the module name when passed no args" do
      expect(instance.version).to be_nil
      instance.version("0.0.1")
      expect(instance.version).to eq("0.0.1")
    end
  end

  context "#dependency" do
    it "should store the dependency name when passed one arg" do
      instance.dependency("foo")
      expect(instance.instance_variable_get(:@dependencies)).to eq([
        {:name => "foo", :version => nil, :repository => nil}
      ])
    end

    it "should store the dependency version when passed two args" do
      instance.dependency("bar", "1.2.3")
      expect(instance.instance_variable_get(:@dependencies)).to eq([
        {:name => "bar", :version => "1.2.3", :repository => nil}
      ])
    end

    it "should store the dependency repository when passed two args" do
      instance.dependency("bar", "1.2.3", "something")
      expect(instance.instance_variable_get(:@dependencies)).to eq([
        {:name => "bar", :version => "1.2.3", :repository => "something"}
      ])
    end

    it "should be able to store multiple dependencies" do
      instance.dependency("foo")
      instance.dependency("bar")
      expect(instance.instance_variable_get(:@dependencies)).to eq([
        {:name => "foo", :version => nil, :repository => nil},
        {:name => "bar", :version => nil, :repository => nil},
      ])
    end
  end

  context "#dependencies" do
    it "should be able to retrieve the stored dependencies" do
      expect(instance.dependencies).to be_empty
      instance.dependency("foo")
      expect(instance.dependencies).to eq([
        {:name => "foo", :version => nil, :repository => nil}
      ])
    end
  end

  %w(summary description project_page license author source).each do |f|
    context "##{f}" do
      it "should not throw a parse error" do
        expect { instance.send(f, "foo") }.to_not raise_error
      end
    end
  end

  context "an unknown method" do
    it "should raise a parse error" do
      expect { instance.foobarbaz("foo") }.to raise_error
    end
  end
end
