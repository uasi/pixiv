require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :c => :console

desc 'start console'
task :console do
  Bundler.with_clean_env do
    console_helper = File.expand_path('../console_helper.rb', __FILE__)
    load_env = File.exist?('.env') ? 'source .env' : 'true'
    exec "#{load_env} && pry -r #{console_helper} -e 'init;'"
  end
end

task :test do
  exec "rspec spec"
end

