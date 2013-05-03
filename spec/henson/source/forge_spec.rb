require "spec_helper"

describe Henson::Source::Forge do
  let(:requirement) { Gem::Requirement.new(">= 0") }

  subject(:it) {
    described_class.new("bar/foo", requirement, "bar/foo")
  }

  it "can be instantiated" do
    expect(Henson::Source::Forge.new("name", "req", "forge")).to_not be_nil
  end

  describe "#fetched?" do
    before do
      it.expects(:version).returns("1.0.0")
    end

    it "returns true if the tarball is cached" do
      it.send(:cache_path).expects(:file?).returns(true)

      expect(it.fetched?).to be_true
    end

    it "returns false if the tarball is not cached" do
      it.send(:cache_path).expects(:file?).returns(false)

      expect(it.fetched?).to be_false
    end
  end

  describe "#version" do
    it "should return the resolved version" do
      it.expects(:resolve_version_from_requirement).with(requirement).once.
        returns("1.0.0")

      expect(it.version).to eq("1.0.0")
    end
  end

  describe "#fetch!" do
    it "should download the tarball" do
      it.send(:cache_dir).expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns("1.0.0").once
      it.expects(:download_module!)
      it.fetch!
    end
  end

  describe "#versions" do
    it "should return an Array of version Strings" do
      it.expects(:fetch_versions_from_api).returns(["0.1.1", "0.1.2"])

      expect(it.versions).to eq(["0.1.1", "0.1.2"])
    end
  end

  describe "#fetch_versions_from_api" do
    it "should query the api for all versions of the module" do
      it.send(:api).expects(:versions_for_module).with("bar/foo").
        returns(["0.1.1", "0.1.2"])

      expect(it.send(:fetch_versions_from_api)).to eq(["0.1.1", "0.1.2"])
    end
  end

  describe "#download_module!" do
    it "should make an API request to download the module" do
      it.send(:api).expects(:versions_for_module).with("bar/foo").
        returns(["0.1.1", "0.1.2"])
      it.send(:api).expects(:download_version_for_module).with(
        "bar/foo", it.send(:version), it.send(:cache_path)
      )

      it.send(:download_module!)
    end
  end

  describe "#cache_dir" do
    it "should return a Pathname object" do
      expect(it.send(:cache_dir)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball directory" do
      path = Pathname.new(Henson.settings[:cache_path]) + "forge"

      expect(it.send(:cache_dir)).to eq(path)
    end
  end

  describe "#cache_path" do
    it "should return a Pathname object" do
      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:cache_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball for this module" do
      path = Pathname.new(Henson.settings[:cache_path]) + "forge"
      path = path + "bar-foo-1.2.3.tar.gz"

      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:cache_path)).to eq(path)
    end
  end

  describe "#clean_up_old_cached_versions" do
    stub_files = [
      "#{Henson.settings[:cache_path]}/github_tarball/bar-foo-0.0.1.tar.gz",
    ]

    it "should remove tarballs for this module only" do
      Dir.expects(:[]).with("#{Henson.settings[:cache_path]}/forge/bar-foo-*.tar.gz").returns(stub_files)
      FileUtils.expects(:rm).with(stub_files.first).once
      it.send(:clean_up_old_cached_versions)
      Dir.unstub(:[])
    end
  end

  describe "#install_path" do
    it "should return a Pathname object" do
      expect(it.send(:install_path)).to be_a(Pathname)
    end

    it "should return the path that the module will be installed into" do
      path = Pathname.new(Henson.settings[:path]) + "foo"

      expect(it.send(:install_path)).to eq(path)
    end
  end
end
