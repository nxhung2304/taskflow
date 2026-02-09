namespace :api do
  namespace :v1 do
    mount_devise_token_auth_for "User", at: "auth", controllers: {
      sessions: "api/v1/auth/sessions"
    }

    resources :users,  only: [] do
      get "me", on: :collection, to: "users#me"
    end

    resources :boards
  end
end
