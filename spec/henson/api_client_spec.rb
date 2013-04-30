require "spec_helper"

require "henson/api_client"

describe Henson::APIClient do
  before(:each) do
    FakeWeb.clean_registry
  end

#   describe "#api_call" do
#     it "should return a parsed JSON document on success" do
#       FakeWeb.register_uri(
#         :get,    "https://api.github.com/test",
#         :body => {:foo => "bar"}.to_json,
#       )
#
#       expect(it.send(:api_call, "/test")).to eq({"foo" => "bar"})
#     end
#
#     it "should append ?access_token if GITHUB_API_TOKEN envvar set" do
#       FakeWeb.register_uri(
#         :get,    "https://api.github.com/test?access_token=foo",
#         :body => {:token => "set"}.to_json,
#       )
#       FakeWeb.register_uri(
#         :get,    "https://api.github.com/test",
#         :body => {:token => "unset"}.to_json,
#       )
#
#       ENV["GITHUB_API_TOKEN"] = "foo"
#       expect(it.send(:api_call, "/test")).to eq({"token" => "set"})
#       ENV.delete("GITHUB_API_TOKEN")
#     end
#
#     it "should return nil if the JSON is malformed" do
#       FakeWeb.register_uri(
#         :get,    "https://api.github.com/test",
#         :body => "{]",
#       )
#
#       expect(it.send(:api_call, "/test")).to be_nil
#     end
#
#     it "should raise an error on 404" do
#       FakeWeb.register_uri(
#         :get,      "https://api.github.com/repos/bar/puppet-foo/tags",
#         :status => ["404", "Not Found"],
#       )
#
#       expect { it.send(:api_call, "/repos/bar/puppet-foo/tags") }.to raise_error(
#         Henson::GitHubTarballNotFound, "Unable to find bar/puppet-foo on GitHub")
#     end
#
#     it "should raise an error on all other failures" do
#       FakeWeb.register_uri(
#         :get, "https://api.github.com/repos/bar/puppet-foo/tags",
#         :status => ["418", "I'm A Teapot"],
#       )
#
#       expect { it.send(:api_call, "/repos/bar/puppet-foo/tags") }.to raise_error(
#         Henson::GitHubAPIError,
#         "GitHub API returned 418 for https://api.github.com/repos/bar/puppet-foo/tags",
#       )
#     end
#   end
#
#   describe "#fetch_versions_from_api" do
#     before(:each) do
#       FakeWeb.register_uri(
#         :get, "https://api.github.com/repos/bar/puppet-foo/tags",
#         :body => [
#           {"name" => "1.0.0"},
#           {"name" => "0.9.9-rc1"},
#           {"name" => "v2.1.0"},
#         ].to_json,
#       )
#     end
#
#     it "should return a list of version numbers" do
#       expect(it.send(:fetch_versions_from_api)).to be_a(Array)
#       expect(it.send(:fetch_versions_from_api)).to have(3).items
#     end
#
#     it "should strip leading v from version numbers" do
#       expect(it.send(:fetch_versions_from_api)).to include("2.1.0")
#       expect(it.send(:fetch_versions_from_api)).to_not include("v2.1.0")
#     end
#
#     it "should raise an error if no data is returned from the api" do
#       FakeWeb.register_uri(
#         :get,    "https://api.github.com/repos/bar/puppet-foo/tags",
#         :body => nil,
#       )
#       expect { it.send(:fetch_versions_from_api) }.to raise_error(
#         Henson::GitHubAPIError,
#         "No data returned from https://api.github.com/repos/bar/puppet-foo/tags"
#       )
#     end
#   end
#
#   describe "#download_file" do
#     it "should download the file" do
#       FakeWeb.register_uri(
#         :get,    "https://test.com/test/file",
#         :body => "Yay1",
#       )
#
#       File.expects(:open).with("/tmp/test", "wb").returns(StringIO.new)
#       it.send(:download_file, "https://test.com/test/file", "/tmp/test")
#       File.unstub(:open)
#     end
#
#     it "should follow redirects" do
#       FakeWeb.register_uri(
#         :get,        "https://test.com/test/file",
#         :status   => ["301", "Moved Permanently"],
#         :location => "https://test.com/test/file2",
#       )
#       FakeWeb.register_uri(
#         :get,    "https://test.com/test/file2",
#         :body => "Yay2",
#       )
#
#       File.expects(:open).with("/tmp/test", "wb").returns(StringIO.new)
#       it.send(:download_file, "https://test.com/test/file", "/tmp/test")
#       File.unstub(:open)
#     end
#
#     it "should raise an error on failure" do
#       FakeWeb.register_uri(
#         :get,      "https://test.com/test/file",
#         :status => ["404", "Not Found"],
#       )
#
#       expect { it.send(:download_file, "https://test.com/test/file", "/tmp/test") }.to raise_error(
#         Henson::GitHubDownloadError,
#         "GitHub returned 404 for https://test.com/test/file"
#       )
#     end
#   end
end
