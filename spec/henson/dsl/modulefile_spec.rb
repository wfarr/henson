require 'spec_helper'

describe Henson::DSL::Modulefile do
  let(:instance) { described_class.new }

  context ".evaluate" do
    it "creates a new instance and calls evaluate" do
      described_class.expects(:initialize).returns(instance)
      instance.expects(:evaluate).with('spec/fixtures/Modulefile')
      described_class.evaluate('spec/fixtures/Modulefile')
    end
  end

  context "#evaluate" do
    it "raises ModulefileError if a syntax error is encountered" do
      expect {
        described_class.evaluate('spec/fixtures/Modulefile.with_syntax_error')
      }.to raise_error(
        Henson::ModulefileError,
        /Modulefile syntax error:/
      )
    end

    it "raises ModulefileError if a ScriptError is encountered" do
      file = 'spec/fixtures/Modulefile.with_script_error'

      expect { described_class.evaluate(file) }.to raise_error(
        Henson::ModulefileError,
        /There was an error parsing #{file}, Henson can not continue\./
      )
    end

    it "raises ModulefileError if a RegexpError is encountered" do
      file = 'spec/fixtures/Modulefile.with_regexp_error'

      expect { described_class.evaluate(file) }.should raise_error(
        Henson::ModulefileError,
        /There was an error parsing #{file}, Henson can not continue\./
      )
    end

    it "raises ModulefileError if a NameError is encountered" do
      file = 'spec/fixtures/Modulefile.with_name_error'

      expect { described_class.evaluate(file) }.should raise_error(
        Henson::ModulefileError,
        /There was an error parsing #{file}, Henson can not continue\./
      )
    end

    it "raises ModulefileError if an ArgumentError is encountered" do
      file = 'spec/fixtures/Modulefile.with_argument_error'

      expect { described_class.evaluate(file) }.should raise_error(
        Henson::ModulefileError,
        /There was an error parsing #{file}, Henson can not continue\./
      )
    end

    it "raises VersionMissingError if no version declared" do
      file = 'spec/fixtures/Modulefile.without_version'

      expect {
        described_class.evaluate(file)
      }.should raise_error(Henson::VersionMissingError, 'foobar')
    end
  end

  context '#name' do
    it 'should store the module name when passed an arg' do
      instance.name('test')
      instance.instance_variable_get(:@name).should == 'test'
    end

    it 'should retrieve the module name when passed no args' do
      instance.name.should be_nil
      instance.name('test2')
      instance.name.should == 'test2'
    end
  end

  context '#version' do
    it 'should store the module version when passed an arg' do
      instance.version('0.0.0')
      instance.instance_variable_get(:@version).should == '0.0.0'
    end

    it 'should retrieve the module name when passed no args' do
      instance.version.should be_nil
      instance.version('0.0.1')
      instance.version.should == '0.0.1'
    end
  end

  context '#dependency' do
    it 'should store the dependency name when passed one arg' do
      instance.dependency('foo')
      instance.instance_variable_get(:@dependencies).should == [
        {:name => 'foo', :version => nil, :repository => nil}
      ]
    end

    it 'should store the dependency version when passed two args' do
      instance.dependency('bar', '1.2.3')
      instance.instance_variable_get(:@dependencies).should == [
        {:name => 'bar', :version => '1.2.3', :repository => nil}
      ]
    end

    it 'should store the dependency repository when passed two args' do
      instance.dependency('bar', '1.2.3', 'something')
      instance.instance_variable_get(:@dependencies).should == [
        {:name => 'bar', :version => '1.2.3', :repository => 'something'}
      ]
    end

    it 'should be able to store multiple dependencies' do
      instance.dependency('foo')
      instance.dependency('bar')
      instance.instance_variable_get(:@dependencies).should == [
        {:name => 'foo', :version => nil, :repository => nil},
        {:name => 'bar', :version => nil, :repository => nil},
      ]
    end
  end

  context '#dependencies' do
    it 'should be able to retrieve the stored dependencies' do
      instance.dependencies.should be_empty
      instance.dependency('foo')
      instance.dependencies.should == [
        {:name => 'foo', :version => nil, :repository => nil}
      ]
    end
  end

  %w(summary description project_page license author source).each do |f|
    context "##{f}" do
      it 'should not throw a parse error' do
        expect { instance.send(f, 'foo') }.to_not raise_error
      end
    end
  end

  context 'an unknown method' do
    it 'should raise a parse error' do
      expect { instance.foobarbaz('foo') }.to raise_error
    end
  end
end
