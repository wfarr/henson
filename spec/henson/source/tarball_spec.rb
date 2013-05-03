require "spec_helper"

describe Henson::Source::Tarball do
  subject(:it) { described_class.new("foo", ">= 0", "whatever") }

  describe "#name" do
    it "should return the name of the module" do
      expect(it.name).to eq("foo")
    end
  end

  describe "#api" do
    it "should return the api object" do
      it.send(:set_instance_variable, "@api", :foo)
      expect(it.api).to eq(:foo)
    end
  end

  describe "#version" do
    it "should return the resolved version" do
      it.expects(:resolve_version_from_requirement).with(">= 0").once.returns("1.0.0")
      expect(it.version).to eq("1.0.0")
    end
  end

  describe "#versions" do
    it "should make a single call to the API" do
      it.expects(:fetch_versions_from_api).returns(["1.0.0"]).once
      expect(it.versions).to eq(["1.0.0"])
      expect(it.versions).to eq(["1.0.0"])
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

  describe "#fetch!" do
    it "should download the tarball" do
      it.send(:cache_path).expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns("1.0.0").once
      it.expects(:download!)
      it.fetch!
    end
  end

  describe "#install!" do
    it "should extract the tarball into the install path" do
      it.expects(:version).at_least_once.returns("1.0.0")
      it.send(:install_path).expects(:exist?).returns(true)
      it.send(:install_path).expects(:rmtree)
      it.send(:install_path).expects(:mkpath)
      it.expects(:extract_tarball).with(it.send(:tarball_path).to_path, it.send(:install_path).to_path)
      it.install!
    end
  end
end
