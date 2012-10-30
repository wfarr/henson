require 'spec_helper'

describe Henson::PuppetModule do
  describe "module with opts" do
    describe "that are valid" do
      let(:mod) { Henson::PuppetModule.new 'example', '0', :path => "/foo/bar/baz" }

      it "must have a source" do
        mod.source.should_not be_nil
      end
    end

    describe "that are invalid" do
      it "aborts with a message" do
        lambda {
          Henson::PuppetModule.new 'example', '0', :foo => 'bar'
        }.should raise_error(SystemExit, "Invalid source for example")
      end
    end
  end
end