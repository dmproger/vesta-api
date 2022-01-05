server '18.132.47.22', user: 'ubuntu', roles: %w{web app db}

set :application, 'vesta-rails'
set :repo_url, 'git@github.com:dmproger/vesta-api.git'
# set :repo_url, 'git@github.com:vesta-tech/rails.git'
set :branch, :master
set :deploy_to, '/home/ubuntu/vesta-rails'
set :pty, true
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{tmp/pids tmp/sockets log tmp/cache vendor/bundle public/system public/uploads}
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.7.0'

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false

set :default_env, {
  'SANDBOX_ENV' => 'false',
  'ADMIN_NAME' => 'admin',
  'ADMIN_PASSWORD' => '466f45767ece027ad0f4be76e9b60d92',
  # 'TWILLIO_ACCOUNT_SID' => 'fill it',
  # 'TWILLIO_AUTH_TOKEN' => 'fill it',
  # 'TWILLIO_FROM_NUMBER' => 'fill it'
}

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"

set :delayed_job_workers
set :delayed_job_roles, %i(app background)

set :ssh_options, {
    keys: %w(vesta-prod-rails.pem),
    forward_agent: true,
    auth_methods: %w(publickey)
}
