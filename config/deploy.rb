# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'nimble_in'
set :repo_url, 'git@bitbucket.org:teknuk/camp_one.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'
append :linked_files, 'config/database.yml', '.env'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Default value for config_example_suffix is '-example'
set :config_example_suffix, '.sample'

################
# CUSTOM_TASKS #
################

namespace :rails do
  # https://github.com/capistrano/sshkit/blob/master/EXAMPLES.md
  desc 'Interact with a remote bash shell using sshkit-interactive'
  task :bash do
    run_interactively primary(fetch(:console_role)), shell: fetch(:console_shell) do
      within current_path do
        as user: fetch(:console_user) do
          execute(:bash)
        end
      end
    end
  end

  # # https://stackoverflow.com/questions/9569070/how-to-enter-rails-console-on-production-via-capistrano
  # desc 'Open ssh `cap [staging] ssh [server_index default: 0]`'
  # task :ssh do
  #   server = roles(:app)[ARGV[2].to_i]
  #   puts "Opening a console on: #{server.hostname}…."
  #   cmd = "ssh #{server.user}@#{server.hostname}"
  #   puts cmd
  #   exec cmd
  # end
end

##################
# RBENV Defaults #
##################

# set :rbenv_type, :user # or :system, depends on your rbenv setup # default :user
# set :rbenv_ruby, '2.6.0'

# in case you want to set ruby version from the file:
# set :rbenv_ruby, File.read('.ruby-version').strip

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# set :rbenv_map_bins, %w{rake gem bundle ruby rails}
# set :rbenv_roles, :all # default value

#########################################
# PUMA and NGINX related configurations #
#########################################

# use preload_app! to take advantage of Ruby 2 'Copy on Write' optimization
# Preload Puma app, default false
set :puma_preload_app, true

# setup ActiveRecord connection pool and prevent connection leakage
# Init ActiveRecord for Puma, default false
set :puma_init_active_record, true

# Daemonize Puma, default false
set :puma_daemonize, true

# Set role for nginx_config, default :web
# set :puma_nginx, %w{root@example.com}

#################
# PUMA Defaults #
#################

# set :puma_user, fetch(:user)
# set :puma_rackup, -> { File.join(current_path, 'config.ru') }
# set :puma_state, "#{shared_path}/tmp/pids/puma.state"
# set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
# set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
# set :puma_control_app, false
# set :puma_default_control_app, "unix://#{shared_path}/tmp/sockets/pumactl.sock"
# set :puma_conf, "#{shared_path}/puma.rb"
# set :puma_access_log, "#{shared_path}/log/puma_access.log"
# set :puma_error_log, "#{shared_path}/log/puma_error.log"
# set :puma_role, :app
# set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
# set :puma_threads, [0, 16]
# set :puma_workers, 0
# set :puma_worker_timeout, nil
# set :puma_init_active_record, false
# set :puma_preload_app, false
# set :puma_daemonize, false
# set :puma_plugins, []  #accept array of plugins
# set :puma_tag, fetch(:application)

##################
# NGINX Defaults #
##################

# set :nginx_config_name, "#{fetch(:application)}_#{fetch(:stage)}"
# set :nginx_flags, 'fail_timeout=0'
# set :nginx_http_flags, fetch(:nginx_flags)
# set :nginx_server_name, "localhost #{fetch(:application)}.local"
# set :nginx_sites_available_path, '/etc/nginx/sites-available'
# set :nginx_sites_enabled_path, '/etc/nginx/sites-enabled'
# set :nginx_socket_flags, fetch(:nginx_flags)
# set :nginx_ssl_certificate, "/etc/ssl/certs/{fetch(:nginx_config_name)}.crt"
# set :nginx_ssl_certificate_key, "/etc/ssl/private/{fetch(:nginx_config_name)}.key"
# set :nginx_use_ssl, false

