`ssh-add`

set :application, "my_app"
set :repo_url, "git@github.com:xx/xxx.git"
set :whenever_identifier, -> {"#{fetch(:application)}_#{fetch(:stage)}"}
set :passenger_restart_with_touch, true

shared_dirs = %w(
log
tmp/pids
tmp/cache
tmp/sockets
public/system
public/uploads
node_modules
storage
)
append :linked_dirs, *shared_dirs

shared_files = %w(
config/database.yml
config/secrets.yml
config/sidekiq.yml
config/application.yml
)
append :linked_files, *shared_files

namespace :deploy do
  after :finishing, :'passenger:restart'
  after :finishing, :setup
  after :finishing, :clear_bootsnap
end

task :setup do
  shared_dirs.each do |dir|
    command %[mkdir -p "#{fetch(:shared_path)}/#{dir}"]
    command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/#{dir}"]
  end

  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]

  command %[touch "#{fetch(:shared_path)}/config/application.yml"]
  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/application.yml'"]

  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/database.yml'"]
end

desc "Clear bootsnap cache"
task :clear_bootsnap do
  command %[echo "Clear bootsnap cache..."]
  command %[rm -rf "#{fetch(:shared_path)}/tmp/bootsnap-*"]
end

