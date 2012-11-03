require 'spec_helper'

describe Henson::Settings do
  context "initialize" do
    it "defaults quiet to false" do
      Henson::Settings.new[:quiet].should be_false
    end

    it "defaults verbose to false" do
      Henson::Settings.new[:verbose].should be_false
    end

    it "defaults puppetfile to Puppetfile" do
      puppetfile = "#{Dir.pwd}/Puppetfile"
      Henson::Settings.new[:puppetfile].should eql puppetfile
    end

    it "defaults path to shared" do
      shared = "#{Dir.pwd}/shared"
      Henson::Settings.new[:path].should eql shared
    end
  end

  context "[]" do
    it "delegates to fetch" do
      instance = Henson::Settings.new
      instance['foo'].should be_nil
      instance['foo'] = :bar
      instance['foo'].should eql :bar
    end
  end
end