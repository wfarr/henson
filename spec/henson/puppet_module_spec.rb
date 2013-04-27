require 'spec_helper'

describe Henson::PuppetModule do
  context "module with opts" do
    context "that are valid" do
      let(:mod) do
        Henson::PuppetModule.new 'example', '0',
          :path => "spec/fixtures/modules/foobar"
      end

      it "must have a source" do
        expect(mod.source).to_not be_nil
      end

      context "#fetched?" do
        it "delegates to the source" do
          mod.source.stubs(:fetched?).returns(true)
          expect(mod).to be_fetched
        end
      end

      context "#installed?" do
        it "delegates to the source" do
          mod.source.stubs(:installed?).returns(true)
          expect(mod).to be_installed
        end
      end

      context "satisfied?" do
        let(:source) { Henson::Source::Generic.new }

        before do
          mod.stubs(:source).returns(source)
        end

        it "returns true if the source satisfies the requirement" do
          source.stubs(:satisfies?).with(mod.requirement).returns(true)
          expect(mod).to be_satisfied
        end

        it "returns false if the source does not satisfy the requirement" do
          source.stubs(:satisfies?).with(mod.requirement).returns(false)
          expect(mod).to_not be_satisfied
        end
      end

      context "#needs_fetching?" do
        it "returns true if fetched? is false" do
          mod.stubs(:fetched?).returns(false)
          expect(mod).to be_needs_fetching
        end

        it "returns false if fetched? is true" do
          mod.stubs(:fetched?).returns(true)
          expect(mod).to_not be_needs_fetching
        end
      end

      context "#needs_installing?" do
        before do
          mod.stubs(:satisfied?).returns(true)
          mod.stubs(:installed?).returns(true)
        end

        it "returns true if not satisfied" do
          mod.stubs(:satisfied?).returns(false)
          expect(mod).to be_needs_installing
        end

        it "returns true if not installed" do
          mod.stubs(:installed?).returns(false)
          expect(mod).to be_needs_installing
        end

        it "returns false if satisfied and installed" do
          expect(mod).to_not be_needs_installing
        end
      end

      context "#fetch!" do
        it "delegates to the source" do
          mod.source.stubs(:fetch!).returns(:fetched)
          expect(mod.fetch!).to eq(:fetched)
        end
      end

      context "#install!" do
        it "delegates to the source" do
          mod.source.stubs(:install!).returns(:installed)
          expect(mod.install!).to eq(:installed)
        end
      end

      context "#versions" do
        it "delegates to the source" do
          mod.source.stubs(:versions).returns(['1.1', '1.2'])
          expect(mod.versions).to eq(['1.1', '1.2'])
        end
      end
    end

    context "that are invalid" do
      it "aborts with a message" do
        expect {
          Henson::PuppetModule.new 'example', '0', :foo => 'bar'
        }.to raise_error(
          Henson::PuppetfileError,
          "Source given for example is invalid: {:foo=>\"bar\"}"
        )
      end
    end
  end
end
