require 'spec_helper'

describe Henson::Source::GitHubTarball do
  it "can be instantiated" do
    expect(Henson::Source::GitHubTarball.new('foo')).to_not be_nil
  end
end
