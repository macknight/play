# config valid only for current version of Capistrano
lock '3.4.0'

server "192.168.1.8", :web, :app, :db, primary: true


set :application, 'play'
set :repo_url, 'git@github.com:macknight/#{application}.git'
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :user_sudo, false

set :scm, "git"
set :branch, "master"

# Default value for :pty is false
set :pty, true
ssh_options[:forward_agent] = true


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  %w[start stop restart].each do |command|
  	desc "#{command} unicorn server"
  	task command, roles: :app, except: { no_release: true } do
  		run "/etc/init.d/unicorn_#{application} #{command}"
  	end
  end

  desc "make sure local git is in sync with remote"
  task :check_revision, roles: :web do
  	unless `git rev-parse HEAD` == `git rev-parse origin/master`
  		puts "Warning: HEAD is not the same as origin/master"
  		puts "Run `git push` to sync changes"
  		exit
  	end
  end
  before "deploy", "deploy::check_revision"

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
