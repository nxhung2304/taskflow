Rails.application.routes.draw do
  mount_avo

  get "up" => "rails/health#show", as: :rails_health_check
end
