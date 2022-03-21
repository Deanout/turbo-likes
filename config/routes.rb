Rails.application.routes.draw do
  root 'tweets#index'
  resources :tweets
  devise_for :users

  # like_tweet_path(tweet)
  post 'like/:id', to: 'tweets#like', as: 'like_tweet'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
