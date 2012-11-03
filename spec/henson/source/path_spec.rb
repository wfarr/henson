require 'spec_helper'

describe Henson::Source::Path do
  let(:source) do
    Henson::Source::Path.new("spec/fixtures/modules/foobar")
  end

  it "can be instantiated" do
    source.should_not be_nil
  end

  it "is a subclass of Henson::Source::Generic" do
    source.kind_of? Henson::Source::Generic
  end

  context "versions" do
    it "returns an array that contains version from modulefile" do
      source.stubs(:version_from_modulefile).returns('1.0.0')
      source.versions.should eql(['1.0.0'])
    end
  end

  context "valid?" do
    it "returns true if path_exists? is true" do
      source.stubs(:path_exists?).returns(true)
      source.send(:valid?).should be_true
    end

    it "returns false if path_exists? is false" do
      source.stubs(:path_exists?).returns(false)
      source.send(:valid?).should be_false
    end
  end

  context "path_exists?" do
    it "returns true if path is defined and is a directory" do
      source.send(:path_exists?).should be_true
    end

    it "returns false if path is not a directory" do
      source.stubs(:path).returns("/not/a/real/path")
      source.send(:path_exists?).should be_false
    end
  end

  context 'version_from_modulefile' do
    it 'parses the Modulefile to get the version string' do
      source.send(:version_from_modulefile).should == '0.0.1'
    end

    it "raises ModuleNotFound if path DNE" do
      source.stubs(:path_exists?).returns(false)
      lambda {
        source.send(:version_from_modulefile)
      }.should raise_error(
        Henson::ModuleNotFound,
        "spec/fixtures/modules/foobar"
      )
    end
  end
end
