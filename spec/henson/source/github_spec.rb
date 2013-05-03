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
      it.expects(:version).returns("1.1.2").at_least(3)

      ui.expects(:debug).
        with("Downloading bar/puppet-foo@1.1.2 to /Users/wfarr/src/henson/.henson/cache/github/foo-1.1.2.tar.gz...")

      it.send(:api).expects(:download_tag_for_repo).with(
        'bar/puppet-foo',
        '1.1.2',
        '/Users/wfarr/src/henson/.henson/cache/github/foo-1.1.2.tar.gz'
      )

      it.send(:download!)
    end
  end
end
