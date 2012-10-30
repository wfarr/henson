require 'spec_helper'

describe Henson::Source do
  describe "infer_from_opts" do
    it "raises an error if opts hash is empty" do
      lambda {
        Henson::Source.infer_from_opts
      }.should raise_error Henson::InvalidSourceError
    end

    it "returns a Source::File if opts includes file" do
      source = Henson::Source.infer_from_opts :file => '/foo/bar/baz'
      source.should be_a Henson::Source::File
    end
  end
end