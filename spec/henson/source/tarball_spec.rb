require "spec_helper"

describe Henson::Source::Tarball do
  subject(:it) { described_class.new("foo", ">= 0", "whatever") }

  describe "#version" do
    it "should return the resolved version" do
      it.expects(:resolve_version_from_requirement).with(">= 0").once.returns("1.0.0")
      expect(it.version).to eq("1.0.0")
    end
  end

  describe "#fetched?" do
    it "should return true if the tarball exists on disk" do
      it.expects(:version).returns("1.0.0")
      it.send(:tarball_path).expects(:file?).returns(true)
      expect(it.fetched?).to be_true
    end

    it "should return false if the tarball does not exist" do
      it.expects(:version).returns("1.0.0")
      it.send(:tarball_path).expects(:file?).returns(false)
      expect(it.fetched?).to be_false
    end
  end
end
