require 'sequel'
require 'rubocop'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
$: << File.expand_path(File.join(__dir__, "config"))

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['*.rb']
  task.fail_on_error = false
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :test => :spec

task default: [:rubocop, :test]

task :database do
  require "database"
end

desc 'Manages database'
namespace :db do
  desc 'Migrate database'
  task :migrate => :database do
    require "sequel/extensions/migration"
    Sequel::IntegerMigrator.new(DB, File.expand_path("../config/migrations", __FILE__)).run
  end

  task :migrate_down => :database do
    require "sequel/extensions/migration"
    Sequel::IntegerMigrator.new(DB, File.expand_path("../config/migrations", __FILE__), :target => 0).run
  end
end
