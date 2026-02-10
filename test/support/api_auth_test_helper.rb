module ApiAuthTestHelper
  def auth_headers_for(user)
    user ||= users(:one)

    user.save!

    @auth_headers = user.create_new_auth_token
    user.reload

    @auth_headers
  end
end
