require 'spec_helper'
require 'henson/friendly_errors'

describe "Henson.friendly_errors" do
  errors = [
    Henson::PuppetfileError,
    Henson::ModulefileError,
    Henson::PuppetfileNotFound,
    Henson::ModulefileNotFound,
    Henson::ModuleNotFound
  ]

  errors.each do |error|
    it "rescues #{error.name}" do
      lambda {
        Henson.with_friendly_errors { raise error }
      }.should_not raise_error(error)
    end
  end
end
