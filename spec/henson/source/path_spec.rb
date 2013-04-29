require "spec_helper"

describe Henson::Source::Path do
  let(:source) do
    Henson::Source::Path.new("foobar", "spec/fixtures/modules/foobar")
  end

  it "can be instantiated" do
    expect(source).to_not be_nil
  end

  it "is a subclass of Henson::Source::Generic" do
    expect(source).to be_a(Henson::Source::Generic)
  end

  it "raises an error if the path does not exist" do
    expect {
      Henson::Source::Path.new("dne", "/does/not/exist")
    }.to raise_error(Henson::ModuleNotFound, "/does/not/exist")
  end

  context "#fetch!" do
    it "is a noop" do
      expect(source.fetch!).to be_nil
    end
  end

  context "#install!" do
    it "logs an install message"
  end

  context "versions" do
    it "returns an array that contains version from modulefile" do
      source.stubs(:version_from_modulefile).returns("1.0.0")
      expect(source.versions).to eq(["1.0.0"])
    end
  end

  context "valid?" do
    it "returns true if path_exists? is true" do
      source.stubs(:path_exists?).returns(true)
      expect(source.send(:valid?)).to be_true
    end

    it "returns false if path_exists? is false" do
      source.stubs(:path_exists?).returns(false)
      expect(source.send(:valid?)).to be_false
    end
  end

  context "path_exists?" do
    it "returns true if path is defined and is a directory" do
      expect(source.send(:path_exists?)).to be_true
    end

    it "returns false if path is not a directory" do
      source.stubs(:path).returns("/not/a/real/path")
      expect(source.send(:path_exists?)).to be_false
    end
  end

  context "version_from_modulefile" do
    it "parses the Modulefile to get the version string" do
      expect(source.send(:version_from_modulefile)).to eq("0.0.1")
    end

    it "defaults to 0 if modulefile does not exist" do
      source.stubs(:path).returns("/not/a/real/path")
      expect(source.send(:version_from_modulefile)).to eq("0")
    end
  end
end
