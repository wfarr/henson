require "spec_helper"

require "henson/api/client"

describe Henson::API::Client do
  describe "#initialize" do
    it "requires a host" do
      expect(lambda { described_class.new }).to \
        raise_error(ArgumentError)

      expect(described_class.new "foo.test").to \
        be_a(described_class)
    end
  end
end
