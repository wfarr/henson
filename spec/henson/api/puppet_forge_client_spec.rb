require "spec_helper"

describe Henson::API::PuppetForgeClient do
  let(:client) { described_class.new "https://forge.puppetlabs.com/" }

  let(:parsed_response_body) do
    {
      "author"    => "wfarr",
      "full_name" =>"wfarr/osx_defaults",
      "name"      => "osx_defaults",
      "desc"      => "Puppet provider for OS X defaults",
      "releases"  => [
        { "version" => "0.1.2" },
        { "version" => "0.1.1" },
        { "version" => "0.1.0" }
      ],
      "tag_list" => ["defaults","osx"]
    }
  end

  describe "#download_version_for_module" do
    let(:response) { mock }

    before do
      client.expects(:get_module).with("wfarr/osx_defaults", {}).
        returns(parsed_response_body)
    end

    it "writes the stream to disk if successful" do
      client.expects(:download).with(
        "wfarr/osx_defaults/0.1.1.tar.gz", "/tmp/foo.tgz", {}
        ).returns("I'm a teapot")

      client.download_version_for_module \
        "wfarr/osx_defaults", "0.1.1", "/tmp/foo.tgz"
    end

    it "raises GitHubDownloadError if the download fails" do
      client.expects(:download).with(
        "wfarr/osx_defaults/0.1.1.tar.gz", "/tmp/foo.tgz", {}
        ).raises(Henson::APIError)

      expect(lambda {
        client.download_version_for_module \
          "wfarr/osx_defaults", "0.1.1", "/tmp/foo.tgz"
      }).to raise_error(Henson::PuppetForgeDownloadError)
    end

    it "raises an internal error if the tag does not exist" do
      expect(lambda {
        client.download_version_for_module \
          "wfarr/osx_defaults", "2.0.0", "/tmp/foo.tgz"
      }).to raise_error(Henson::PuppetModuleNotFound, /Invalid version/)
    end
  end

  describe "#versions_for_module" do
    it "returns an array of version numbers" do
      client.expects(:get_module).with("wfarr/osx_defaults", {}).
        returns(parsed_response_body)

      expect(client.versions_for_module "wfarr/osx_defaults").to \
        eq(["0.1.2", "0.1.1", "0.1.0"])
    end
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
