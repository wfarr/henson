require 'spec_helper'

describe Henson::PuppetModule do
  context "module with opts" do
    context "that are valid" do
      let(:mod) do
        Henson::PuppetModule.new 'example', '0',
          :path => "spec/fixtures/modules/foobar"
      end

      it "must have a source" do
        mod.source.should_not be_nil
      end

      context "satisfied?" do
        let(:source) { Henson::Source::Generic.new }

        before do
          mod.stubs(:source).returns(source)
        end

        it "returns true if the source satisfies the requirement" do
          source.stubs(:satisfies?).with(mod.requirement).returns(true)
          mod.satisfied?.should be_true
        end

        it "returns false if the source does not satisfy the requirement" do
          source.stubs(:satisfies?).with(mod.requirement).returns(false)
          mod.satisfied?.should be_false
        end
      end

      context "#fetch!" do
        it "delegates to the source" do
          mod.source.stubs(:fetch!).returns(:fetched)
          mod.fetch!.should eql :fetched
        end
      end

      context "#install!" do
        it "delegates to the source" do
          mod.source.stubs(:install!).returns(:installed)
          mod.install!.should eql :installed
        end
      end

      context "#versions" do
        it "delegates to the source" do
          mod.source.stubs(:versions).returns(['1.1', '1.2'])
          mod.versions.should eql(['1.1', '1.2'])
        end
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