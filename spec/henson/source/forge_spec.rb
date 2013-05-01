require "spec_helper"

describe Henson::Source::Forge do
  it "can be instantiated" do
    expect(Henson::Source::Forge.new("name", "req", "forge")).to_not be_nil
  end
end
