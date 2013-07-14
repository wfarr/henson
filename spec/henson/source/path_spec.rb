require "spec_helper"

describe Henson::Source::Path do
  subject(:it) {
    Henson::Source::Path.new("foobar", "spec/fixtures/modules/foobar")
  }

  it "can be instantiated" do
    expect(it).to_not be_nil
  end

  it "is a subclass of Henson::Source::Generic" do
    expect(it).to be_a(Henson::Source::Generic)
  end

  it "raises an error if the path does not exist" do
    expect {
      Henson::Source::Path.new("dne", "/does/not/exist")
    }.to raise_error(Henson::ModuleNotFound, "/does/not/exist")
  end

  describe "#fetched?" do
    it "should be true" do
      expect(it.fetched?).to be_true
    end
  end

  context "#fetch!" do
    it "is a noop" do
      expect(it.fetch!).to be_nil
    end
  end

  context "#install!" do
    let(:ui) { double("UI") }

    before do
      Henson.stubs(:ui).returns(ui)
    end

    after do
      Henson.unstub(:ui)
    end

    it "logs an install message" do
      ui.expects(:debug).
        with("Symlinking #{it.send(:path)} to #{it.send(:install_path)}")

      FileUtils.expects(:ln_sf).
        with(it.send(:path), it.send(:install_path).to_path)

      it.install!
    end
  end

  context "versions" do
    it "returns an array that contains version from modulefile" do
      it.stubs(:version_from_modulefile).returns("1.0.0")
      expect(it.versions).to eq(["1.0.0"])
    end
  end

  context "valid?" do
    it "returns true if path_exists? is true" do
      it.stubs(:path_exists?).returns(true)
      expect(it.send(:valid?)).to be_true
    end

    it "returns false if path_exists? is false" do
      it.stubs(:path_exists?).returns(false)
      expect(it.send(:valid?)).to be_false
    end
  end

  context "path_exists?" do
    it "returns true if path is defined and is a directory" do
      expect(it.send(:path_exists?)).to be_true
    end

    it "returns false if path is not a directory" do
      it.stubs(:path).returns("/not/a/real/path")
      expect(it.send(:path_exists?)).to be_false
    end
  end

  describe "#install_path" do
    it "should be a Pathname" do
      expect(it.send(:install_path)).to be_a(Pathname)
    end

    it "returns the expected install path" do
      expect(it.send(:install_path).to_path).to \
        eq("#{Henson.settings[:path]}/foobar")
    end
  end

  context "version_from_modulefile" do
    it "parses the Modulefile to get the version string" do
      expect(it.send(:version_from_modulefile)).to eq("0.0.1")
    end

    it "defaults to 0 if modulefile does not exist" do
      it.stubs(:path).returns("/not/a/real/path")
      expect(it.send(:version_from_modulefile)).to eq("0")
    end
  end
end
