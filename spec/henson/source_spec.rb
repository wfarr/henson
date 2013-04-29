require "spec_helper"

describe Henson::Source do
  describe "infer_from_opts" do
    it "returns nil if opts hash is empty" do
      expect(Henson::Source.infer_from_opts("foo", ">= 0")).to be_nil
    end

    it "returns a Source::Path if opts includes path" do
      source = Henson::Source.infer_from_opts "foobar", ">= 0",
        :path => "spec/fixtures/modules/foobar"

      expect(source).to be_a(Henson::Source::Path)
    end

    it "returns a Source::Forge if opts includes forge" do
      source = Henson::Source.infer_from_opts "whatever", ">= 0",
        :forge => "wfarr/whatever"

      expect(source).to be_a(Henson::Source::Forge)
    end

    it "returns a Source::GitHubTarball if opts includes github" do
      source = Henson::Source.infer_from_opts "something", ">= 0",
        :github => "someone/something"

      expect(source).to be_a(Henson::Source::GitHubTarball)
    end

    it "returns a Source::GitHubTarball if opts includes github_tarball" do
      source = Henson::Source.infer_from_opts "somethingelse", ">= 0",
        :github_tarball => "someone/something"

      expect(source).to be_a(Henson::Source::GitHubTarball)
    end
  end
end
