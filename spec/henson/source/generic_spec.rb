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
end
