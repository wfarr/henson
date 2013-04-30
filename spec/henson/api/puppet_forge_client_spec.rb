require "spec_helper"

require "henson/api/puppet_forge_client"

describe Henson::API::PuppetForgeClient do
  describe "#initialize" do
    it "requires a host" do
      expect(lambda { described_class.new }).to \
        raise_error(ArgumentError)
    end
  end
end
