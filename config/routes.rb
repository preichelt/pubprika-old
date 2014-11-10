Pubprika::Application.routes.draw do

  root "recipes#index"

  # get "/home", to: "pages#home", as: "home"

  resources :recipes, only: [:index, :show]
end
