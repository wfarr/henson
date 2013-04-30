require "spec_helper"

require "henson/api/github_client"

describe Henson::API::GitHubClient do
  let(:client) { described_class.new "api.github.com" }
  let(:foo_tags) do
    [
      {
        "name"        => "v1.0.0",
        "tarball_url" => "https://codeload.github.com/wfarr/puppet-foo/v1.0.0.tar.gz"
      },
      {
        "name" => "v1.1.0",
        "tarball_url" => "https://codeload.github.com/wfarr/puppet-foo/v1.1.0.tar.gz"
      }
    ]
  end

  describe "#tags_for_repo" do
    it "returns an Array of tag Hashes" do
      client.expects(:request).with(:get, "/repos/wfarr/puppet-foo/tags", {}).
        returns(foo_tags)

      expect(client.tags_for_repo("wfarr/puppet-foo").count).to eq(2)
    end
  end

  describe "#download_tag_for_repo" do
    let(:response) { mock }

    before do
      client.expects(:tags_for_repo).with("wfarr/puppet-foo").
        returns(foo_tags)
    end

    it "writes the stream to disk if successful" do
      client.expects(:request).with(:get, foo_tags.last["tarball_url"], {}).
        returns("I'm a teapot")

      client.expects(:write_download).with("/tmp/foo.tgz", "I'm a teapot")

      client.download_tag_for_repo "wfarr/puppet-foo", "v1.1.0", "/tmp/foo.tgz"
    end

    it "raises GitHubDownloadError if the download fails" do
      client.expects(:request).with(:get, foo_tags.last["tarball_url"], {}).
        raises(Henson::APIError)

      expect(lambda {
        client.download_tag_for_repo "wfarr/puppet-foo", "v1.1.0", "/tmp/foo.tgz"
      }).to raise_error(Henson::GitHubDownloadError)
    end

    it "raises an internal error if the tag does not exist" do
      expect(lambda {
        client.download_tag_for_repo "wfarr/puppet-foo", "v2.0.0", "/tmp/foo.tgz"
      }).to raise_error(/invalid tag/)
    end
  end
end
