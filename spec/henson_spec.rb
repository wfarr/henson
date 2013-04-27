require 'spec_helper'

describe Henson do
  context "settings" do
    it "returns an instance of Henson::Settings" do
      expect(Henson.settings).to be_a(Henson::Settings)
    end
  end

  context "VERSION" do
    it "should not be nil" do
      expect(Henson::VERSION).to_not be_nil
    end
  end
end
