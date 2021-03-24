require 'sidekiq/web'

Rails.application.routes.draw do

  # write your routes here

  mount Sidekiq::Web => '/sidekiq'
  #mount ActionCable.server => '/cable'
  root to: 'home#index'
  get '/status', to: 'home#status'
  match "*path", to: "home#error_404", via: :all
end
