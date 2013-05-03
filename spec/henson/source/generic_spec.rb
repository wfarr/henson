require "spec_helper"

describe Henson::Source::Generic do
  subject(:it) { described_class.new }

  it "can be instantiated" do
    expect(it).to_not be_nil
  end

  it "requires subclasses implement fetch!" do
    expect {
      it.fetch!
    }.to raise_error(NotImplementedError)
  end

  it "requires subclasses implement versions" do
    expect {
      it.versions
    }.to raise_error(NotImplementedError)
  end

  context "satisfies?" do
    let(:requirement) { Gem::Requirement.new "~> 1.0.0" }

    it "returns true if any version satisfies the requirement" do
      it.stubs(:versions).returns(["0.8", "1.0.11"])
      expect(it.satisfies?(requirement)).to be_true
    end

    it "returns false if no version satisfies the requirement" do
      it.stubs(:versions).returns(["0.8", "1.6.0"])
      expect(it.satisfies?(requirement)).to be_false
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
end
