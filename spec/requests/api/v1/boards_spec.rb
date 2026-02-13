require "swagger_helper"

RSpec.describe "Boards API", type: :request do
  include_context "authenticated user"

  path "/api/v1/boards" do
    get "List boards" do
      tags "Boards"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"

      response "200", "returns list of boards" do
        schema type: :object,
          properties: {
            boards: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  description: { type: :string, nullable: true },
                  archived_at: { type: :string, format: "date-time", nullable: true },
                  color: { type: :string },
                  visibility: { type: :boolean },
                  position: { type: :integer },
                  created_at: { type: :string, format: "date-time" },
                  updated_at: { type: :string, format: "date-time" }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                total_pages: { type: :integer },
                total_count: { type: :integer }
              }
            }
          }

        before { create_list(:board, 3, user: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["boards"].size).to eq(3)
          expect(data["meta"]).to be_present
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

    post "Create a board" do
      tags "Boards"
      consumes "application/json"
      produces "application/json"

      parameter name: :board, in: :body, schema: {
        type: :object,
        properties: {
          board: {
            type: :object,
            properties: {
              name: { type: :string, example: "My Board" },
              description: { type: :string, example: "Board description" },
              color: { type: :string, example: "#FF5733" },
              visibility: { type: :boolean, example: true }
            },
            required: %w[name]
          }
        }
      }

      response "201", "board created" do
        let(:board) { { board: { name: "New Board", description: "A new board", color: "#FF5733", visibility: true } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("New Board")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:board) { { board: { name: "" } } }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/errors"

        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid@example.com" }
        let(:board) { { board: { name: "Test" } } }

        run_test!
      end
    end
  end

  path "/api/v1/boards/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Board ID"

    let(:existing_board) { create(:board, user: user) }
    let(:id) { existing_board.id }

    get "Show a board" do
      tags "Boards"
      produces "application/json"

      response "200", "returns the board" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            archived_at: { type: :string, format: "date-time", nullable: true },
            color: { type: :string },
            visibility: { type: :boolean },
            position: { type: :integer },
            created_at: { type: :string, format: "date-time" },
            updated_at: { type: :string, format: "date-time" }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["id"]).to eq(existing_board.id)
        end
      end

      response "404", "board not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/errors"

        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid@example.com" }

        run_test!
      end
    end

    put "Update a board" do
      tags "Boards"
      consumes "application/json"
      produces "application/json"

      parameter name: :board, in: :body, schema: {
        type: :object,
        properties: {
          board: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              color: { type: :string },
              visibility: { type: :boolean },
              archived_at: { type: :string, format: "date-time" }
            }
          }
        }
      }

      response "200", "board updated" do
        let(:board) { { board: { name: "Updated Board" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("Updated Board")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:board) { { board: { name: "" } } }

        run_test!
      end

      response "404", "board not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }
        let(:board) { { board: { name: "Test" } } }

        run_test!
      end
    end

    delete "Delete a board" do
      tags "Boards"

      response "204", "board deleted" do
        run_test!
      end

      response "404", "board not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
