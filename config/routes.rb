Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: 'merchants/items'
        collection do
          get 'find', to: 'merchants#find'
          get 'find_all', to: 'merchants#find_all'
        end
      end

      resources :items, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :merchant, to: 'merchants/items#show'
        end
        collection do
          get 'find', to: 'items#find'
          get 'find_all', to: 'items#find_all'
        end
      end
    end
  end
end
