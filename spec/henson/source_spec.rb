require 'spec_helper'

describe Henson::Source do
  describe "infer_from_opts" do
    it "returns nil if opts hash is empty" do
      expect(Henson::Source.infer_from_opts('foo')).to be_nil
    end

    it "returns a Source::Path if opts includes path" do
      source = Henson::Source.infer_from_opts 'foobar',
        :path => 'spec/fixtures/modules/foobar'

      expect(source).to be_a(Henson::Source::Path)
    end

    it "returns a Source::Forge if opts includes forge" do
      source = Henson::Source.infer_from_opts 'whatever',
        :forge => 'wfarr/whatever'

      expect(source).to be_a(Henson::Source::Forge)
    end
  end
end
