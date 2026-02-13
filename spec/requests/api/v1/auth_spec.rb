require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  path "/api/v1/auth" do
    post "Sign up" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      security []

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "John Doe" },
          email: { type: :string, example: "john@example.com" },
          password: { type: :string, example: "password123" },
          password_confirmation: { type: :string, example: "password123" }
        },
        required: %w[name email password password_confirmation]
      }

      response "200", "account created" do
        let(:body) do
          {
            name: "John Doe",
            email: "john@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test!
      end

      response "422", "invalid request" do
        schema "$ref" => "#/components/schemas/errors"

        let(:body) do
          {
            name: "",
            email: "invalid",
            password: "short",
            password_confirmation: "mismatch"
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/auth/sign_in" do
    post "Sign in" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      security []

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "john@example.com" },
          password: { type: :string, example: "password123" }
        },
        required: %w[email password]
      }

      response "200", "signed in successfully" do
        let!(:user) { create(:user, email: "signin@example.com") }
        let(:body) { { email: "signin@example.com", password: "password123" } }

        run_test! do |response|
          expect(response.headers["access-token"]).to be_present
          expect(response.headers["client"]).to be_present
          expect(response.headers["uid"]).to eq("signin@example.com")
        end
      end

      response "401", "invalid credentials" do
        schema "$ref" => "#/components/schemas/errors"

        let(:body) { { email: "wrong@example.com", password: "wrong" } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/sign_out" do
    delete "Sign out" do
      tags "Auth"
      produces "application/json"

      response "200", "signed out successfully" do
        let(:user) { create(:user) }
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:"token-type") { "Bearer" }

        run_test!
      end
    end
  end
end
