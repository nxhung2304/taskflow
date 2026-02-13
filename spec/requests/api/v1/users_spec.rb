require "swagger_helper"

RSpec.describe "Users API", type: :request do
  include_context "authenticated user"

  path "/api/v1/users/me" do
    get "Get current user profile" do
      tags "Users"
      produces "application/json"

      response "200", "returns current user" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            image: { type: :string, nullable: true },
            created_at: { type: :string, format: "date-time" },
            updated_at: { type: :string, format: "date-time" }
          },
          required: %w[id name email]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["email"]).to eq(user.email)
        end
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/errors"

        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid@example.com" }

        run_test!
      end
    end
  end
end
