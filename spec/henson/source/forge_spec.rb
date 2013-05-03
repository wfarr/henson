require "spec_helper"

describe Henson::Source::Forge do
  let(:requirement) { Gem::Requirement.new(">= 0") }

  subject(:it) {
    described_class.new("bar/foo", requirement, "bar/foo")
  }

  it "can be instantiated" do
    expect(Henson::Source::Forge.new("name", "req", "forge")).to_not be_nil
  end

  it "inherits Henson::Source::Tarball" do
    expect(it).to be_a(Henson::Source::Tarball)
  end

  describe "#fetch_versions_from_api" do
    it "should query the api for all versions of the module" do
      it.send(:api).expects(:versions_for_module).with("bar/foo").
        returns(["0.1.1", "0.1.2"])

      expect(it.send(:fetch_versions_from_api)).to eq(["0.1.1", "0.1.2"])
    end
  end

  describe "#download!" do
    let(:ui) { mock }

    before do
      Henson.ui = ui
    end

    it "should make an API request to download the module" do
      ui.expects(:debug).
        with("Downloading bar/foo@#{it.send(:version)} to #{it.send(:cache_path)}")

      it.send(:api).expects(:download_version_for_module).with(
        "bar/foo", it.send(:version), it.send(:cache_path)
      )

      it.send(:download!)
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
