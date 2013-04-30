require "spec_helper"

require "henson/api/github_client"

describe Henson::API::GitHubClient do
  describe "#initialize" do
    it "requires a host" do
      expect(lambda { described_class.new }).to \
        raise_error(ArgumentError)
    end
  end
end
