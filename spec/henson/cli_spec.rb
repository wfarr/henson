require 'spec_helper'
require 'henson/cli'

describe Henson::CLI do
  it "is a subclass of Thor" do
    Henson::CLI.new.should be_a Thor
  end

  context "start" do
    it "responds to start, provided by Thor" do
      Henson::CLI.start
    end
  end
end