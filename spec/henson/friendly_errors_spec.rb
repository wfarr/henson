require "spec_helper"
require "henson/friendly_errors"

describe "Henson.friendly_errors" do
  errors = [
      Henson::PuppetfileError,
      Henson::ModulefileError,
      Henson::PuppetfileNotFound,
      Henson::ModulefileNotFound,
      Henson::ModuleNotFound,

      Henson::GitHubTarballNotFound,
      Henson::GitHubAPIError,
      Henson::GitHubDownloadError,
    ]

  let(:ui) { double("UI") }

  before do
    Henson.stubs(:ui).returns(ui)

    ui.expects(:warn)
  end

  after do
    Henson.unstub(:ui)
  end

  errors.each do |error|
    it "rescues #{error.name}" do
      expect {
        Henson.with_friendly_errors { raise error }
      }.to_not raise_error(error)
    end
  end
end
