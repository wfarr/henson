# Inspired by Bundler.with_friendly_errors

module Henson
  def self.with_friendly_errors
    begin
      yield
    rescue Henson::InvalidSourceError => e
      puts e.message
      exit 1
    end
  end
end