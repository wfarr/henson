require 'spec_helper'
require 'henson/friendly_errors'

describe "Henson.friendly_errors" do
  it "rescues Henson::PuppetfileError" do
    lambda {
      Henson.with_friendly_errors do
        raise Henson::PuppetfileError
      end
    }.should_not raise_error(Henson::PuppetfileError)
  end

  it "rescues Henson::PuppetfileNotFound" do
    lambda {
      Henson.with_friendly_errors do
        raise Henson::PuppetfileNotFound
      end
    }.should_not raise_error(Henson::PuppetfileNotFound)
  end
end