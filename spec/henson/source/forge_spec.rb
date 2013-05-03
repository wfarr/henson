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

  describe "#installed?" do
    it "should always return false" do
      expect(it.installed?).to be_false
    end
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
      it.send(:api).expects(:versions_for_module).with('bar/foo').
        returns(%w(0.1.1 0.1.2)).at_least(3)

      ui.expects(:debug).
        with("Downloading bar/foo@#{it.send(:version)} to #{it.send(:cache_path)}")

      it.send(:api).expects(:download_version_for_module).with(
        'bar/foo',
        '0.1.2',
        '/Users/wfarr/src/henson/.henson/cache/forge/bar-foo-0.1.2.tar.gz'
      )

      it.send(:download!)
    end
  end
end
