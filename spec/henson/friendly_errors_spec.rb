require 'spec_helper'
require 'henson/friendly_errors'

describe "Henson.friendly_errors" do
  it "rescues Henson::InvalidSourceError" do
    lambda {
      Henson.with_friendly_errors do
        raise Henson::InvalidSourceError
      end
    }.should_not raise_error(Henson::InvalidSourceError)
  end
end