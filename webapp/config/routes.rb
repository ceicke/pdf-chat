Rails.application.routes.draw do
  resources :prompts
  resources :questions, only: [:index, :create]
  resource :uploader, only: [:new, :create]

  # Defines the root path route ("/")
  root "questionss#index"
end
