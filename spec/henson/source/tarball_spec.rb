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
      it.expects(:cache_path).returns(dir)
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
      cache_path.expects(:to_path).returns("cache_path")
      install_path.expects(:to_path).returns("install_path")

      it.expects(:install_path).returns(install_path).at_least(3)
      it.expects(:version).at_least_once.returns("1.0.0")
      install_path.expects(:exist?).returns(true)
      install_path.expects(:rmtree)
      install_path.expects(:mkpath)
      it.expects(:extract_tarball).with(
        '/Users/wfarr/src/henson/.henson/cache/tarball/foo-1.0.0.tar.gz',
        'install_path'
      )

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
    it "should return a Pathname object" do
      expect(it.send(:cache_dir)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball directory" do
      path = Pathname.new(Henson.settings[:cache_path]) + "tarball"

      expect(it.send(:cache_dir)).to eq(path)
    end
  end

  describe "#cache_path" do
    it "should return a Pathname object" do
      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:cache_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball for this module" do
      path = Pathname.new(Henson.settings[:cache_path]) + "tarball"
      path = path + "foo-1.2.3.tar.gz"

      it.expects(:version).once.returns("1.2.3")
      expect(it.send(:cache_path)).to eq(path)
    end
  end

  describe "#clean_up_old_cached_versions" do
    stub_files = [
      "#{Henson.settings[:cache_path]}/tarball/foo-0.0.1.tar.gz",
    ]

    it "should remove tarballs for this module only" do
      it.expects(:cached_versions_to_clean).
        returns("#{Henson.settings[:cache_path]}/tarball/bar-foo-*.tar.gz").
        twice

      Dir.expects(:[]).with(it.send(:cached_versions_to_clean)).
        returns(stub_files)

      FileUtils.expects(:rm).with(stub_files.first).once

      it.send(:clean_up_old_cached_versions)

      Dir.unstub(:[])
    end
  end
end
