require 'spec_helper'

describe Henson::Source::GitHubTarball do
  it "can be instantiated" do
    Henson::Source::GitHubTarball.new('foo').should_not be_nil
  end
end