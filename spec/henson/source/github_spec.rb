require "spec_helper"

describe Henson::Source::GitHub do
  subject(:it) { described_class.new("foo", ">= 0", "bar/puppet-foo") }

  it "can be instantiated" do
    expect(it).to_not be_nil
  end

  it "inherits Henson::Source::Tarball" do
    expect(it).to be_a(Henson::Source::Tarball)
  end

  describe "#repo" do
    it "should return the repository name for the module" do
      expect(it.repo).to eq("bar/puppet-foo")
    end
  end

  describe "#installed?" do
    it "should always return false" do
      expect(it.installed?).to be_false
    end
  end

  describe "#fetch_versions_from_api" do
    let(:ui) { double("UI") }

    let(:tags) do
      [
        {
          "name"        => "v1.0.0",
          "tarball_url" => "https://codeload.github.com/bar/puppet-foo/v1.0.0.tar.gz"
        },
        {
          "name" => "v1.1.0",
          "tarball_url" => "https://codeload.github.com/bar/puppet-foo/v1.1.0.tar.gz"
        }
      ]
    end

    before do
      Henson.stubs(:ui).returns(ui)
    end

    after do
      Henson.unstub(:ui)
    end

    it "sends an API request for tags" do
      ui.expects(:debug).
        with("Fetching a list of tag names for #{it.send(:repo)}")

      it.send(:api).expects(:tags_for_repo).with(it.send(:repo)).
        returns(tags)

      expect(it.send(:fetch_versions_from_api)).to eq(%w(1.0.0 1.1.0))
    end

    it "filters out tags that don't match v?d.d(.d+)" do
      ui.expects(:debug).
        with("Fetching a list of tag names for #{it.send(:repo)}")

      it.send(:api).expects(:tags_for_repo).with(it.send(:repo)).
        returns(tags + [{"name" => "1.0RC23" }])

      expect(it.send(:fetch_versions_from_api)).to eq(%w(1.0.0 1.1.0))
    end
  end

  describe "#download!" do
    let(:ui) { double("UI") }

    before do
      Henson.stubs(:ui).returns(ui)
    end

    after do
      Henson.unstub(:ui)
    end

    it "should make an API request to download the module" do
      it.expects(:version).returns("1.1.2").at_least(3)

      ui.expects(:debug).
        with("Downloading #{it.send(:repo)}@#{it.send(:version)} to #{it.send(:cache_path).to_path}...")

      it.send(:api).expects(:download_tag_for_repo).with(
        'bar/puppet-foo',
        it.send(:version),
        it.send(:cache_path).to_path
      )

      it.send(:download!)
    end
  end
end
