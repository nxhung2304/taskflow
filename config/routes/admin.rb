devise_for :admin_users

namespace :admin do
  root to: "home#index"
  resources :boards
end
