require 'spec_helper'

describe Henson::Source do
  describe "infer_from_opts" do
    it "returns nil if opts hash is empty" do
      Henson::Source.infer_from_opts.should be_nil
    end

    it "returns a Source::Path if opts includes path" do
      source = Henson::Source.infer_from_opts(
        :path => 'spec/fixtures/modules/foobar'
      )

      source.should be_a Henson::Source::Path
    end

    it "returns a Source::Forge if opts includes forge" do
      source = Henson::Source.infer_from_opts :forge => 'wfarr/whatever'
      source.should be_a Henson::Source::Forge
    end
  end
end