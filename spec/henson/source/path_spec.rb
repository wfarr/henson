require 'spec_helper'

describe Henson::Source::Path do
  let(:instance) do
    Henson::Source::Path.new("test")
  end

  it "can be instantiated" do
    instance.should_not be_nil
  end

  it "is a subclass of Henson::Source::Generic" do
    instance.kind_of? Henson::Source::Generic
  end

  context "valid?" do
    it "returns true if path_exists? is true" do
      instance.stubs(:path_exists?).returns(true)
      instance.send(:valid?).should be_true
    end

    it "returns false if path_exists? is false" do
      instance.stubs(:path_exists?).returns(false)
      instance.send(:valid?).should be_false
    end
  end

  context "path_exists?" do
    it "returns true if path is defined and is a directory" do
      source = Henson::Source::Path.new("spec/fixtures/modules/foobar")
      source.send(:path_exists?).should be_true
    end

    it "returns false if path is not a directory" do
      source = Henson::Source::Path.new("/prolly/wont/exist")
      source.send(:path_exists?).should be_false
    end
  end

  context 'version_from_modulefile' do
    it 'parses the Modulefile to get the version string' do
      source = Henson::Source::Path.new('spec/fixtures/modules/foobar')
      source.send(:version_from_modulefile).should == '0.0.1'
    end
  end
end
