Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"

  draw(:admin)
  draw(:api)
end
