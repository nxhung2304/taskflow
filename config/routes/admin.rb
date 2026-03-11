devise_for :admin_users

namespace :admin do
  root to: "home#index"
  resource :locale, only: [ :update ]
  resources :boards do
    resources :lists
  end

  resources :lists, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    resources :tasks
  end
end
