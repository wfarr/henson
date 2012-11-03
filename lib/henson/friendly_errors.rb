# Inspired by Bundler.with_friendly_errors

module Henson
  def self.with_friendly_errors
    begin
      yield
    rescue PuppetfileError, ModulefileError => e
      Henson.ui.error   e.message
      Henson.ui.warning e.backtrace.join("\n")
      exit e.exit_code
    rescue PuppetfileNotFound => e
      Henson.ui.error "Could not find Puppetfile!"
      exit e.exit_code
    rescue ModuleNotFound => e
      Henson.ui.error "Could not find module: #{e.message}"
    end
  end
end
