require 'spec_helper'

describe Henson::Installer do
  before do
    Henson.reset_settings
    Henson.settings[:puppetfile] = File.expand_path("spec/fixtures/Puppetfile")
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

  context "parse_puppetfile!" do
    it "raises MissingPuppetfileError if no Puppetfile" do
      lambda {
        Henson.settings[:puppetfile] = '/path/to/no/Puppetfile'
        Henson::Installer.parse_puppetfile!
      }.should raise_error(
        Henson::PuppetfileNotFound,
        "Expected a Puppetfile at /path/to/no/Puppetfile!"
      )
    end
  end
end