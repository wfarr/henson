require "spec_helper"

require "henson/api/client_cache"

describe Henson::API::ClientCache do
  let(:cache) { described_class.new }

  describe "#initialize" do
    it "returns an instance of a client cache" do
      expect(described_class.new).to be_a(described_class)
    end

    it "creates the clients hash" do
      expect(described_class.new.clients).to be_a(Hash)
    end
  end

  describe "#github" do
    it "caches a GitHubClient per host" do
      expect(cache.github("https://api.github.com/")).to \
        be_a(Henson::API::GitHubClient)

      expect(cache.github "https://api.github.com/").to \
        be_equal(cache.github "https://api.github.com/")
    end
  end

  describe "#puppet_forge" do
    it "caches a PuppetForgeClient per host" do
      expect(cache.puppet_forge "https://forge.puppetlabs.com/").to \
        be_a(Henson::API::PuppetForgeClient)

      expect(cache.puppet_forge "https://forge.puppetlabs.com/").to \
        be_equal(cache.puppet_forge "https://forge.puppetlabs.com/")
    end
  end
end
