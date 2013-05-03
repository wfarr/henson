require "spec_helper"

describe Henson::Source::GitHubTarball do
  subject(:it) { described_class.new("foo", ">= 0", "bar/puppet-foo") }

  it "can be instantiated" do
    expect(it).to_not be_nil
  end

  it "inherits Henson::Source::Generic" do
    expect(it).to be_a(Henson::Source::Generic)
  end

  describe "#name" do
    it "should return the name of the module" do
      expect(it.name).to eq("foo")
    end
  end

  describe "#repo" do
    it "should return the repository name for the module" do
      expect(it.repo).to eq("bar/puppet-foo")
    end
  end

  describe "#fetch!" do
    it "should download the tarball" do
      it.send(:cache_path).expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns("1.0.0").at_least(3)
      it.expects(:download_tag_tarball).with(it.send(:tarball_path).to_path)
      it.fetch!
    end
  end

  describe "#installed?" do
    it "should always return false" do
      expect(it.installed?).to be_false
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

  describe "#versions" do
    it "should make a single call to the API" do
      it.expects(:fetch_versions_from_api).returns(["1.0.0"]).once
      expect(it.versions).to eq(["1.0.0"])
      expect(it.versions).to eq(["1.0.0"])
    end
  end

  describe "#cache_path" do
    it "should return a Pathname object" do
      expect(it.send(:cache_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball directory" do
      path = Pathname.new(Henson.settings[:cache_path]) + "github_tarball"

      expect(it.send(:cache_path)).to eq(path)
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
