require 'spec_helper'
require 'henson/cli'

describe Henson::CLI do
  before do
    Henson.reset_settings
    Henson.settings[:puppetfile] = File.expand_path("spec/fixtures/Puppetfile")
  end

  it "is a subclass of Thor" do
    Henson::CLI.new.should be_a Thor
  end

  context "start" do
    it "responds to start, provided by Thor" do
      Henson::CLI.start
    end

    it "ENV['HENSON_PUPPETFILE'] sets settings[:puppetfile]" do
      ENV['HENSON_PUPPETFILE'] = File.expand_path("/path/to/nowhere")
      Henson::CLI.new
      Henson.settings[:puppetfile].should eql("/path/to/nowhere")
      ENV['HENSON_PUPPETFILE'] = nil
    end
  end

  context "install" do
    before do
      Henson::Installer.stubs(:install)
    end

    context "options" do
      it "sets local if --local" do
        ARGV = ["install", "--local"]
        Henson::CLI.start
        Henson.settings[:local].should be_true
      end

      it "sets no_cache if --no-cache" do
        ARGV = ["install", "--no-cache"]
        Henson::CLI.start
        Henson.settings[:no_cache].should be_true
      end

      it "sets clean if --clean" do
        ARGV = ["install", "--clean"]
        Henson::CLI.start
        Henson.settings[:clean].should be_true
      end
    end
  end
end