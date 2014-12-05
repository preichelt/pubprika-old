Pubprika::Application.routes.draw do

  root "recipes#index"

  get "/about", to: "pages#about", as: "about"

  resources :recipes, only: [:index, :show] do
    collection do
      get :random
    end
  end
end
