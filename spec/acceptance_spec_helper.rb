$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'rspec'
require 'mocha_standalone'

RSpec.configure do |config|
  config.before(:suite) do
    get_your_setup_on
  end

  config.after(:suite) do
    tear_that_shit_down
  end
end

def root
  @root ||= File.expand_path('../../', __FILE__)
end

def tmpdir
  @tmpdir ||= File.expand_path('./tmp/acceptance', root)
end

def get_your_setup_on
  FileUtils.mkdir_p tmpdir

  Dir.chdir(tmpdir) do
    clone = system 'git', 'clone', 'https://github.com/wfarr/dubserv'

    abort("fuuuu") unless clone

    FileUtils.ln_s "#{root}", "#{tmpdir}/henson"

    Dir.chdir("#{tmpdir}/dubserv") do
      system 'bundle'
    end
  end
end

def tear_that_shit_down
  FileUtils.rm_rf tmpdir
end
