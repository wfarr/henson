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

  describe "#download!" do
    let(:ui) { mock }

    before do
      Henson.ui = ui
    end

    it "should make an API request to download the module" do
      ui.expects(:debug).
        with("Downloading bar/puppet-foo@#{it.send(:version)} to #{it.send(:cache_path)}")

      it.send(:api).expects(:download_tag_for_repo).with(
        "bar/puppet-foo", it.send(:version), it.send(:cache_path)
      )

      it.send(:download!)
    end
  end

  describe "#tarball_path" do
    it "should return a Pathname object" do
      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:tarball_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball for this module" do
      path = Pathname.new(Henson.settings[:cache_path]) + "github_tarball"
      path = path + "bar-puppet-foo-1.2.3.tar.gz"

      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:tarball_path)).to eq(path)
    end
  end

  describe "#clean_up_old_cached_versions" do
    stub_files = [
      "#{Henson.settings[:cache_path]}/github_tarball/bar-puppet-foo-0.0.1.tar.gz",
    ]

    it "should remove tarballs for this module only" do
      Dir.expects(:[]).with("#{Henson.settings[:cache_path]}/github_tarball/bar-puppet-foo-*.tar.gz").returns(stub_files)
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
