module Henson
  class UI
    attr_writer :shell

    def initialize(shell)
      @shell = shell
    end

    def debug(message)
      log message if debug?
    end

    def info(message)
      log message unless quiet? || debug?
    end

    def warning(message)
      log message, :yellow
    end

    def error(message)
      log message, :red
    end

    def debug!
      Henson.settings[:verbose] = true
    end

    def debug?
      Henson.settings[:verbose]
    end

    def quiet!
      Henson.settings[:quiet] = true
    end

    def quiet?
      Henson.settings[:quiet]
    end

    private
    def log(message, color = nil)
      @shell.say message, color
    end
  end
end