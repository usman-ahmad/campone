require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)
set :domain, '45.33.2.211'
set :deploy_to, '/home/teknuk/camp_one'
set :repository, 'git@bitbucket.org:teknuk/camp_one.git'
set :branch, 'fe-refactoring'
set :user, 'teknuk'
set :forward_agent, true

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', '.env', 'public/system']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
set :port, '22'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'
  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.3.0@camp-one]'
  queue 'source ~/.nvm/nvm.sh'
  queue 'nvm use v6.4.0;'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/public/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/system"]

  ['sec']
  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/.env"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'. and '.env'."]


  # TODO FIX THESE LINES, DID NOT WORKED
  # You can manually add bitbucket to known hosts i-e  ssh -vT git@bitbucket.org (on your server) enter yes when promoted
  # queue %[
  #   repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
  #   repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
  #   if [ -z "${repo_port}" ]; then repo_port=22; fi &&
  #   ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  # ]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      # queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      # queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"

      queue "if [ -f #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid ] && [ -e /proc/$(cat #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid) ]; then kill -9 `cat #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid`; fi"
      queue "RAILS_ENV=production bundle exec rackup private_pub.ru -s thin -E production -P #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid -D"

      # queue "bundle exec thin -s 2 -a 127.0.0.1 -p 7000 -e #{rails_env} -u #{user} -l #{deploy_to}/#{shared_path}/log/thin.log -P #{deploy_to}/#{shared_path}/tmp/pids/thin.pid restart -d"

      queue "bundle exec pumactl -F  #{deploy_to}/#{current_path}/config/puma/production.rb stop"
      queue "bundle exec pumactl -F  #{deploy_to}/#{current_path}/config/puma/production.rb start"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers


namespace :thin do
  task :restart => :environment do
    queue "cd #{deploy_to}/current;bundle exec thin -s 2 -a 127.0.0.1 -p 7000 -e #{rails_env} -u #{user} -l #{deploy_to}/#{shared_path}/log/thin.log -P #{deploy_to}/#{shared_path}/tmp/pids/thin.pid restart -d"
  end
  task :stop => :environment do
    queue "cd #{deploy_to}/current;bundle exec thin -s 2 -a 127.0.0.1 -p 7000 -e #{rails_env} -u #{user} -l #{deploy_to}/#{shared_path}/log/thin.log -P #{deploy_to}/#{shared_path}/tmp/pids/thin.pid stop -d"
  end
end


namespace :puma do
  task :restart => :environment do
    queue "cd #{deploy_to}/current;bundle exec thin -s 2 -a 127.0.0.1 -p 7000 -e #{rails_env} -u #{user} -l #{deploy_to}/#{shared_path}/log/thin.log -P #{deploy_to}/#{shared_path}/tmp/pids/thin.pid restart -d"
  end
  task :stop => :environment do
    queue "cd #{deploy_to}/current;bundle exec thin -s 2 -a 127.0.0.1 -p 7000 -e #{rails_env} -u #{user} -l #{deploy_to}/#{shared_path}/log/thin.log -P #{deploy_to}/#{shared_path}/tmp/pids/thin.pid stop -d"
  end
end

namespace :private_pub do
  desc "Start private_pub server"
  task :start => :environment  do
    queue "cd #{deploy_to}/current;RAILS_ENV=production bundle exec rackup private_pub.ru -s thin -E production -P #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid -D"
    # queue "cd #{deploy_to}/#{shared_path};RAILS_ENV=production bundle exec rackup private_pub.ru -s thin -E production -D -P tmp/pids/private_pub.pid"
  end

  desc "Stop private_pub server"
  task :stop => :environment  do
    queue "if [ -f #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid ] && [ -e /proc/$(cat #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid) ]; then kill -9 `cat #{deploy_to}/#{shared_path}/tmp/pids/private_pub.pid`; fi"
  end

  desc "Restart private_pub server"
  task :restart => :environment do
    invoke :'private_pub:stop'
    invoke :'private_pub:start'
  end
end
