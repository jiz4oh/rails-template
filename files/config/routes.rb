require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do

  # write your routes here

  mount Sidekiq::Web => '/sidekiq'
  #mount ActionCable.server => '/cable'
  root to: 'home#index'
  get '/status', to: 'home#status'
  match "*path", to: "home#error_404", via: :all
end
