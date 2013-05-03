require "spec_helper"

describe Henson::Source::Tarball do
  subject(:it) { described_class.new("foo", ">= 0", "whatever") }

  it "inherits Henson::Source::Generic" do
    expect(it).to be_a(Henson::Source::Generic)
  end

  describe "#name" do
    it "should return the name of the module" do
      expect(it.name).to eq("foo")
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
    let(:file) { mock }
    let(:dir)  { mock }

    it "should return true if the tarball exists on disk" do
      it.expects(:version).returns("1.0.0")
      it.expects(:cache_path).returns(file)
      file.expects(:file?).returns(true)
      expect(it.fetched?).to be_true
    end

    it "should return false if the tarball does not exist" do
      it.expects(:version).returns("1.0.0")
      it.expects(:cache_path).returns(dir)
      dir.expects(:file?).returns(false)
      expect(it.fetched?).to be_false
    end
  end

  describe "#fetch!" do
    let(:dir) { mock }

    it "should download the tarball" do
      it.expects(:cache_dir).returns(dir)
      dir.expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns("1.0.0").once
      it.expects(:download!)
      it.fetch!
    end
  end

  describe "#install!" do
    let(:cache_path)   { mock }
    let(:install_path) { mock }

    it "should extract the tarball into the install path" do
      cache_path.expects(:to_path).returns("cache_path").times(2)
      install_path.expects(:to_path).returns("install_path").times(2)

      it.expects(:install_path).returns(install_path).times(5)

      it.expects(:cache_path).returns(cache_path).times(3)

      it.expects(:version).at_least_once.returns("1.0.0")

      install_path.expects(:exist?).returns(true)
      install_path.expects(:rmtree)
      install_path.expects(:mkpath)

      it.expects(:extract_tarball).with(
        it.send(:cache_path).to_path,
        it.send(:install_path).to_path
      )

      cache_path.expects(:rmtree).never

      it.install!
    end

    it "should also remove the cache tarball of no cache mode is enabled" do
      Henson.settings[:no_cache] = true

      cache_path.expects(:to_path).returns("cache_path").times(2)
      install_path.expects(:to_path).returns("install_path").times(2)

      it.expects(:install_path).returns(install_path).times(5)

      it.expects(:cache_path).returns(cache_path).times(3)

      it.expects(:version).at_least_once.returns("1.0.0")

      install_path.expects(:exist?).returns(true)
      install_path.expects(:rmtree)
      install_path.expects(:mkpath)

      it.expects(:extract_tarball).with(
        it.send(:cache_path).to_path,
        it.send(:install_path).to_path
      )

      cache_path.expects(:rmtree).once

      it.install!
    end
  end

  describe "#extract_tarball" do
    let(:ui) { mock }

    before do
      Henson.ui = ui
    end

    it "should be able to extract files" do
      stubbed_file = stub(
        :file?     => true,
        :full_name => "bar-foo-124351ab/manifests/test.pp",
        :read      => "file contents",
      )
      Zlib::GzipReader.expects(:open).with("/tmp/tarball.tar.gz").returns(nil)
      Gem::Package::TarReader.expects(:new).with(nil).returns([stubbed_file])
      File.expects(:open).with("/tmp/manifests/test.pp", "wb").returns(StringIO.new)

      ui.expects(:debug).with("Extracting /tmp/tarball.tar.gz to /tmp")

      it.send(:extract_tarball, "/tmp/tarball.tar.gz", "/tmp")

      File.unstub(:open)
      Gem::Package::TarReader.unstub(:new)
      Zlib::GzipReader.unstub(:open)
    end

    it "should be able to create directories" do
      stubbed_dir = stub(
        :file?      => false,
        :directory? => true,
        :full_name  => "bar-foo-125234a/manifests/foo",
      )
      Zlib::GzipReader.expects(:open).with("/tmp/tarball.tar.gz").returns(nil)
      Gem::Package::TarReader.expects(:new).with(nil).returns([stubbed_dir])
      FileUtils.expects(:mkdir_p).with("/tmp/manifests/foo")

      ui.expects(:debug).with("Extracting /tmp/tarball.tar.gz to /tmp")

      it.send(:extract_tarball, "/tmp/tarball.tar.gz", "/tmp")

      FileUtils.unstub(:mkdir_p)
      Gem::Package::TarReader.unstub(:new)
      Zlib::GzipReader.unstub(:open)
    end
  end

  describe "#cache_dir" do
    before do
      Henson.expects(:settings).
        returns({ :no_cache => false, :cache_path => "/cache_path" })
    end

    it "should return a Pathname object" do
      expect(it.send(:cache_dir)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball directory" do
      expect(it.send(:cache_dir)).to \
        eq(Pathname.new("/cache_path") + "tarball")
    end
  end

  describe "#cache_path" do
    before do
      it.expects(:version).once.returns("1.2.3")
    end

    it "should return a Pathname object" do
      expect(it.send(:cache_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball for this module" do
      expect(it.send(:cache_path)).to \
        eq(Pathname.new("/cache_path") + "tarball" + "foo-1.2.3.tar.gz")
    end
  end

  describe "#clean_up_old_cached_versions" do
    let(:cache_path) { mock }
    let(:files)      { ["/cache_path/tarball/foo-0.0.1.tar.gz"] }

    it "should remove tarballs for this module only" do
      it.expects(:cache_path).returns(cache_path)

      it.expects(:version).returns("1.0.0")

      cache_path.expects(:to_path).
        returns("/cache_path/tarball/bar-foo-1.0.0.tar.gz")

      Dir.expects(:[]).with("/cache_path/tarball/bar-foo-*.tar.gz").
        returns(files)

      FileUtils.expects(:rm).with(files.first).once

      it.send(:clean_up_old_cached_versions)

      Dir.unstub(:[])
    end
  end

  describe "#install_path" do
    before do

    end

    it "should return a Pathname object" do
      expect(it.send(:install_path)).to be_a(Pathname)
    end

    it "should return the path that the module will be installed into" do
      expect(it.send(:install_path)).to eq(Pathname.new("/path") + "foo")
    end
  end
end
