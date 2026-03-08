devise_for :admin_users

namespace :admin do
  root to: "home#index"
  resource :locale, only: [ :update ]
  resources :boards
end
