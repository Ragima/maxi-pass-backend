lock '~> 3.11.0'
set :application, 'maxipass_v2'
set :repo_url, 'git@bitbucket.org:maxiwidgets/maxipass_v2.git'
set :rvm_ruby_version, '2.3.1@maxipass_v2'

# Deploy to the user's home directory
set :deploy_to, "/home/ubuntu/apps/#{fetch :application}"
set :passenger_restart_with_touch, true

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/.env', 'config/master.key'

set :keep_releases, 3

task :restart_sidekiq do
  invoke 'sidekiq:rolling_restart'
end

namespace :deploy do
  after :restart, :restart_sidekiq
end
