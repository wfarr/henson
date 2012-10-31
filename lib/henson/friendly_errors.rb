# Inspired by Bundler.with_friendly_errors

module Henson
  def self.with_friendly_errors
    begin
      yield
    rescue Henson::InvalidSourceError => e
      Henson.ui.error   e.message
      Henson.ui.warning e.backtrace.join("\n")
      exit 1
    end
  end
end