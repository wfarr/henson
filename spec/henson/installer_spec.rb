require 'spec_helper'

describe Henson::Installer do
  before do
    Henson.reset_settings
  end

  it "implements install!" do
    Henson::Installer.install!
  end

  it "local! makes local setting true" do
    Henson.settings[:local].should_not be_true
    Henson::Installer.local!
    Henson.settings[:local].should be_true
  end

  it "no_cache! makes no_cache setting true" do
    Henson.settings[:no_cache].should_not be_true
    Henson::Installer.no_cache!
    Henson.settings[:no_cache].should be_true
  end

  it "clean! makes clean setting true" do
    Henson.settings[:clean].should_not be_true
    Henson::Installer.clean!
    Henson.settings[:clean].should be_true
  end
end