require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(-fp --color)
    t.ruby_opts  = %w(-w)
  end
rescue LoadError
  puts "You must run `bundle` to install development dependencies."
end

desc "List TODOs"
task :todo do
  dirs = %w(lib spec)
  lines = {}

  dirs.each do |dir|
    Dir["#{dir}/**/*"].each do |path|
      if File.directory? path
        next
      elsif path =~ /.*\.rb$/
        line_num = 0

        File.readlines(path).each do |line|
          line_num += 1
          next unless line =~ /TODO/

          unless lines.fetch(path, nil)
            lines[path] = []
          end

          lines[path] = lines[path] + [{ :number => line_num, :line => line }]
        end
      end
    end
  end
  lines.each do |path, matches|
    puts "#{path}:"

    matches.each do |match|
      sanitized = match[:line].gsub(/(^.*TODO)/, "").strip
      puts "  * TODO L#{match[:number]}: #{sanitized}"
    end
  end
end
