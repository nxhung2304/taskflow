module DeviseAdminHelpers
  def sign_in_admin(admin_user)
    post admin_user_session_path, params: {
      admin_user: {
        email: admin_user.email,
        password: admin_user.password
      }
    }
  end
end

RSpec.configure do |config|
  config.include DeviseAdminHelpers, type: :request
end
