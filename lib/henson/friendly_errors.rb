# Inspired by Bundler.with_friendly_errors

module Henson
  def self.with_friendly_errors
    begin
      yield
    rescue PuppetfileError, ModulefileError => e
      Henson.ui.error   e.message
      Henson.ui.warning e.backtrace.join("\n")
      exit e.exit_code
    rescue PuppetfileNotFound, ModulefileNotFound => e
      Henson.ui.error "#{e.message}, but it does not exist!"
      exit e.exit_code
    rescue ModuleNotFound => e
      Henson.ui.error "Could not find module: #{e.message}"
    rescue GitInvalidRef => e
      Henson.ui.error e.message
      exit e.exit_code
    end
  end
end
