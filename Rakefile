require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(-fs --color)
    t.ruby_opts  = %w(-w)
  end
rescue LoadError
  puts "You must run `bundle` to install development dependencies."
end
