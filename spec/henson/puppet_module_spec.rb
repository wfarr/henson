require 'spec_helper'

describe Henson::PuppetModule do
  context "module with opts" do
    context "that are valid" do
      let(:mod) { Henson::PuppetModule.new 'example', '0', :path => "/foo/bar/baz" }

      it "must have a source" do
        mod.source.should_not be_nil
      end
    end

    context "that are invalid" do
      it "aborts with a message" do
        lambda {
          Henson::PuppetModule.new 'example', '0', :foo => 'bar'
        }.should raise_error(
          Henson::PuppetfileError,
          "Source given for example is invalid: {:foo=>\"bar\"}"
        )
      end
    end
  end
end