require "spec_helper"

describe Henson::Source::Forge do
  subject(:it) { described_class.new("bar/foo", ">= 0", "bar/foo") }

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
      it.expects(:resolve_version_from_requirement).with(">= 0").once.
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
end
