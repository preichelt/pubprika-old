Pubprika::Application.routes.draw do

  root "recipes#index"

  # get "/home", to: "pages#home", as: "home"

  resources :recipes, only: [:index, :show] do
    collection do
      get :random
    end
  end
end
