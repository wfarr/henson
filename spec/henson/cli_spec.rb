require 'spec_helper'
require 'henson/cli'

describe Henson::CLI do
  context "run" do
    it "is defined" do
      Henson::CLI.run
    end

    it "passes args onto initialize" do
      Henson::CLI.expects(:initialize).with('foo', 'bar', 'baz')
      Henson::CLI.run 'foo', 'bar', 'baz'
    end
  end
end