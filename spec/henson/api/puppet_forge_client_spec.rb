require "spec_helper"

require "henson/api/puppet_forge_client"

describe Henson::API::PuppetForgeClient do
  let(:client) { described_class.new "forge.puppetlabs.com" }

  let(:parsed_response_body) do
    {
      "author"    => "wfarr",
      "full_name" =>"wfarr/osx_defaults",
      "name"      => "osx_defaults",
      "desc"      => "Puppet provider for OS X defaults",
      "releases"  => [
        { "version" => "0.1.2"},
        { "version" => "0.1.1"},
        { "version" => "0.1.0"}
      ],
      "tag_list" => ["defaults","osx"]
    }
  end

  describe "#versions_for_module" do

  end

  describe "#get_module" do
    it "returns a Hash of module metadata if the request succeeds" do
      client.expects(:request).with(:get, "wfarr/osx_defaults", {}).
        returns(parsed_response_body)

      results = client.get_module "wfarr/osx_defaults"

      expect(results).to be_a(Hash)
      expect(results["releases"]).to be_a(Array)
      expect(results["author"]).to eq("wfarr")
    end

    it "raises an error if the request fails" do
      client.expects(:request).with(:get, "wfarr/osx_defaults", {}).
        raises(Henson::APIError)

      expect(lambda { client.get_module "wfarr/osx_defaults" }).to \
        raise_error(Henson::PuppetModuleNotFound)
    end
  end
end
