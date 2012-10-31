require 'spec_helper'

describe Henson do
  context "settings" do
    it "returns an instance of Henson::Settings" do
      Henson.settings.should be_a Henson::Settings
    end
  end

  context "VERSION" do
    it "should not be nil" do
      Henson::VERSION.should_not be_nil
    end
  end
end