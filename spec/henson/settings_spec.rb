require "spec_helper"

describe Henson::Settings do
  context "initialize" do
    it "defaults quiet to false" do
      expect(Henson::Settings.new[:quiet]).to be_false
    end

    it "defaults verbose to false" do
      expect(Henson::Settings.new[:verbose]).to be_false
    end

    it "defaults puppetfile to Puppetfile" do
      puppetfile = "#{Dir.pwd}/Puppetfile"
      expect(Henson::Settings.new[:puppetfile]).to eq(puppetfile)
    end

    it "defaults path to shared" do
      shared = "#{Dir.pwd}/shared"
      expect(Henson::Settings.new[:path]).to eq(shared)
    end
  end

  context "[]" do
    it "delegates to fetch" do
      instance = Henson::Settings.new
      expect(instance["foo"]).to be_nil
      instance["foo"] = :bar
      expect(instance["foo"]).to eq(:bar)
    end
  end
end
