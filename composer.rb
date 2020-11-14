require_relative 'composer_helper'

$USE_CUSTOM_CONFIG = no? 'Would you like to setup default configs? [y|n]'

$DEST_APP_ROOT_PATH = ask_for_config('What dir would you like to deploy on the server', '/home/deploy/apps')
DEVISE_MODEL_NAME = ask_for_config('What would you like the user model to be called?', "user")
GIT_REPO_URL = ask_for_config('Where is git repository?', 'localhost')
DEPLOY_SERVER = ask_for_config('Where do you want to deploy?', 'localhost')
DEPLOY_USER = ask_for_config('Who would you like to deploy on the server?', 'deploy')

say 'remove Gemfile comments'
remove_comments('Gemfile')

say 'Begin apply gems'
say 'apply rspec test framework...'
gem_group :development do
  gem 'rails_apps_testing'
end
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end
gem_group :test do
  gem 'database_cleaner'
end
after_bundle do
  generate 'testing:configure', 'rspec --force'
end

say 'apply rails-i18n...'
gem 'rails-i18n', '~> 6.0.0'

say 'apply postgresql...'
remove_gem('sqlite3')
gem 'pg', '>= 1.1'
get_remote('config/database.yml.example', 'config/database.yml')

say 'apply redis'
gem 'redis'

say 'apply sidekiq...'
gem 'sidekiq', '~> 5'
get_remote('config/initializers/sidekiq.rb')
get_remote('config/sidekiq.yml.example', 'config/sidekiq.yml')
application "config.active_job.queue_adapter = :sidekiq"

say 'apply bcrypt...'
gem 'bcrypt'

say 'apply devise'
gem 'devise'
gem 'devise-i18n'
after_bundle do
  generate "devise:install"
  generate "devise", DEVISE_MODEL_NAME
end

say 'apply cancancan'
gem 'cancancan'
after_bundle do
  generate 'cancan:ability'
end

say 'apply kaminari'
gem 'kaminari', '~> 1.1.1'
after_bundle do
  generate 'kaminari:config'
end

say 'apply capistrano & its plugins...'
gem "capistrano", "~> 3", require: false
gem 'capistrano-sidekiq', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-rvm', require: false
gem 'capistrano-passenger', require: false
gem 'capistrano3-nginx', require: false
get_remote('Capfile')
get_remote('config/deploy.rb')
create_file 'config/deploy/production.rb' do
  <<-EOF.strip_heredoc
    set :repo_url, '#{GIT_REPO_URL}'
    set :branch, :master
    server '#{DEPLOY_SERVER}', user: '#{DEPLOY_USER}', roles: %w{app db web}
    set :deploy_to, "/data/www/\#{fetch(:application)}"
    set :ssh_options, {forward_agent: true}
  EOF
end
create_file 'config/deploy/staging.rb' do
  <<-EOF.strip_heredoc
    set :repo_url, '#{GIT_REPO_URL}'
    set :branch, :staging
    server '#{DEPLOY_SERVER}', user: '#{DEPLOY_USER}', roles: %w{app db web}
    set :deploy_to, "/data/www/\#{fetch(:application)}_staging"
    set :ssh_options, {forward_agent: true}
  EOF
end

say 'apply figaro & secret config'
gem 'figaro'
get_remote('config/application.yml.example', 'config/application.yml')
get_remote('config/spring.rb')
get_remote('config/secret.yml.example', 'config/secret.yml')
after_bundle do
  say "Stop spring if exists"
  run "spring stop"
end

say 'apply sentry'
gem 'sentry-raven'
get_remote('config/initializers/sentry.rb')
say 'End apply gems'

say 'apply action cable config...'
environment %[config.action_cable.allowed_request_origins = [ "\#{ENV['PROTOCOL']}://\#{ENV['DOMAIN']}" ]], env: :production

say 'apply application config...'
application do
  <<-EOF.strip_heredoc
    config.generators.assets = false
    config.generators.helper = false

    config.time_zone = 'Beijing'
    config.i18n.available_locales = [:en, :'zh-CN']
    config.i18n.default_locale = :'zh-CN'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'models', '*.{rb,yml}').to_s]
  EOF
end
get_remote('config/routes.rb')

say 'apply other config'
get_remote('config/puma.rb')
get_remote('config/nginx.conf.example')
get_remote('config/nginx.ssl.conf.example')
get_remote('config/logrotate.conf.example')
get_remote('db/seeds.rb')
get_remote 'bin/setup'
get_remote 'README.md'
get_remote('gitignore', '.gitignore')

say 'Handle assets'
remove_dir 'app/assets'
# Fix error: Expected to find a manifest file in app/assets/config/manifest.js
run 'mkdir -p app/assets/config && echo ' ' > app/assets/config/manifest.js'

say 'apply controllers'
inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do
  <<-EOF.strip_heredoc
    include RenderExtension
  EOF
end
controller_files = %w(
home_controller.rb
)
get_remote_dir(controller_files, 'app/controllers')
concern_files = %w(
errors.rb
render_extension.rb
)
get_remote_dir(concern_files, 'app/controllers/concerns')

after_bundle do
  say 'Almost done! Now init `git` and `database`...'
  rails_command 'db:drop'
  rails_command 'db:create'
  git :init
  git add: '.'
  git commit: '-m "init rails with jiz4oh/rails-template"'
  say "Build successfully! `cd #{app_name}` First, then start `./bin/webpack-dev-server` first, input `rails s` to start your rails app..."
end
