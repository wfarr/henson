require "spec_helper"

describe Henson::Source::Forge do
  it "can be instantiated" do
    expect(Henson::Source::Forge.new("foo", "foo")).to_not be_nil
  end
end
