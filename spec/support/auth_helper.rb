module AuthHelper
  def auth_headers_for(user)
    post "/api/v1/auth/sign_in", params: { email: user.email, password: "password123" }
    {
      "access-token" => response.headers["access-token"],
      "client" => response.headers["client"],
      "uid" => response.headers["uid"],
      "token-type" => "Bearer"
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end

RSpec.shared_context "authenticated user" do
  let(:user) { create(:user) }
  let(:auth) { auth_headers_for(user) }
  let(:"access-token") { auth["access-token"] }
  let(:client) { auth["client"] }
  let(:uid) { auth["uid"] }
  let(:"token-type") { "Bearer" }
end
