set :repo_url, "git@github.com:xx/xxx.git"
set :branch, :staging
set :deploy_user, 'ruby'
server 'xxx', user: fetch(:deploy_user), roles: %w{app db web}
set :deploy_to, "/data/www/#{fetch(:application)}_staging"
set :ssh_options, {forward_agent: true}
