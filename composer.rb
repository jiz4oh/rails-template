TEMPLATE_REPO_URL = 'https://raw.githubusercontent.com/jiz4oh/rails-template/master/files/'
DEST_APP_ROOT_PATH = '/home/deploy/apps'

def remove_gem(*names)
  names.each do |name|
    gsub_file 'Gemfile', /gem '#{name}'.*\n/, ''
  end
end

def replace_myapp(file)
  gsub_file file, /myapp/, app_name, verbose: false
end

def replace_app_root_path(file)
  gsub_file file, /\/data\/www/, DEST_APP_ROOT_PATH, verbose: false
end

def get_remote(src, dest = src)
  if ENV['RAILS_TEMPLATE_DEBUG'].present?
    repo = File.join(File.dirname(__FILE__), 'files/')
  else
    repo = TEMPLATE_REPO_URL
  end
  remote_file = repo + src
  get(remote_file, dest, force: true)
  replace_myapp(dest)
  replace_app_root_path(dest)
end

def get_remote_dir(names, dir)
  names.each do |name|
    src = File.join(dir, name)
    get_remote(src)
  end
end

def remove_dir(dir)
  run("rm -rf #{dir}")
end

say 'remove comments'
gsub_file('Gemfile', /^\s*#.*$\n/, '')

say 'Begin apply gems'
say 'apply postgresql...'
remove_gem('sqlite3')
gem 'pg', '>= 1.1'
get_remote('config/database.yml.example', 'config/database.yml')

# environment variables set
say 'apply figaro...'
gem 'figaro'
get_remote('config/application.yml.example', 'config/application.yml')
get_remote('config/spring.rb')
after_bundle do
  say "Stop spring if exists"
  run "spring stop"
end

say 'apply redis & sidekiq...'
gem 'redis'
gem 'sidekiq', '~> 5'
get_remote('config/initializers/sidekiq.rb')
get_remote('config/sidekiq.yml')
inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
  <<-EOF
    config.active_job.queue_adapter = :sidekiq
  EOF
end

say 'apply bcrypt...'
gem 'bcrypt'

say 'apply devise & its plugins...'
gem 'devise'
gem 'devise-i18n'
after_bundle do
  generate 'devise:install'
  generate 'devise Admin'
end

say 'apply cancancan'
gem 'cancancan'
after_bundle do
  generate 'cancan:ability'
end

say 'apply rails-i18n...'
gem 'rails-i18n', '~> 6.0.0'

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
get_remote('config/deploy.rb')
deploy_environments = %w(
production.rb
staging.rb
)
get_remote_dir(deploy_environments, 'config/deploy')

say 'apply annotate'
gem 'annotate'

say 'apply sentry'
gem "sentry-raven"
get_remote('config/initializers/sentry.rb')

say 'apply rspec test framework...'
gem_group :development do
  gem 'rails_apps_testing'
end
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end
gem_group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end
after_bundle do
  generate 'testing:configure', 'rspec --force'
end
say 'End apply gems'

say 'apply action cable config...'
inject_into_file 'config/environments/production.rb', after: "# Mount Action Cable outside main process or domain.\n" do
  <<-EOF
  config.action_cable.allowed_request_origins = [ "\#{ENV['PROTOCOL']}://\#{ENV['DOMAIN']}" ]
  EOF
end

say 'apply application config...'
inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
  <<-EOF
    config.generators.assets = false
    config.generators.helper = false

    config.time_zone = 'Beijing'
    config.i18n.available_locales = [:en, :'zh-CN']
    config.i18n.default_locale = :'zh-CN'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'models', '*.{rb,yml}').to_s]
  EOF
end
get_remote('config/routes.rb')
get_remote('config/secret.yml')

say 'apply other config'
get_remote('config/puma.rb')
get_remote('config/nginx.conf.example')
get_remote('config/nginx.ssl.conf.example')
get_remote('config/logrotate.conf.example')
get_remote('config/monit.conf.example')
get_remote('config/backup.rb.example')
get_remote('db/seeds.rb')
get_remote 'bin/setup'
get_remote 'README.md'
get_remote('gitignore', '.gitignore')

say 'Handle assets'
remove_dir 'app/assets'
# Fix error: Expected to find a manifest file in app/assets/config/manifest.js
run "mkdir -p app/assets/config && echo '{}' > app/assets/config/manifest.js"
get_remote('app/javascript/images/favicon.ico')

say 'apply controllers'
inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do
  <<-EOF
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
