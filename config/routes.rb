Rails.application.routes.draw do
  draw "avo"
  mount_avo

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"
end
