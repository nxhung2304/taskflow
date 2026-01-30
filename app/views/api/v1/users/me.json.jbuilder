json.user do
  json.partial! "api/v1/shared/user", user: current_user
end

json.success true
