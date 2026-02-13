require "swagger_helper"

RSpec.describe "Lists API", type: :request do
  include_context "authenticated user"

  let(:board) { create(:board, user: user) }

  path "/api/v1/boards/{board_id}/lists" do
    parameter name: :board_id, in: :path, type: :integer, description: "Board ID"
    let(:board_id) { board.id }

    get "List all lists in a board" do
      tags "Lists"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"

      response "200", "returns lists" do
        schema type: :object,
          properties: {
            lists: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  position: { type: :integer },
                  board_id: { type: :integer },
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

        before { create_list(:list, 3, board: board) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["lists"].size).to eq(3)
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

    post "Create a list" do
      tags "Lists"
      consumes "application/json"
      produces "application/json"

      parameter name: :list, in: :body, schema: {
        type: :object,
        properties: {
          list: {
            type: :object,
            properties: {
              name: { type: :string, example: "To Do" }
            },
            required: %w[name]
          }
        }
      }

      response "201", "list created" do
        let(:list) { { list: { name: "To Do" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("To Do")
          expect(data["board_id"]).to eq(board.id)
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:list) { { list: { name: "" } } }

        run_test!
      end
    end
  end

  path "/api/v1/lists/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "List ID"
    let(:existing_list) { create(:list, board: board) }
    let(:id) { existing_list.id }

    get "Show a list" do
      tags "Lists"
      produces "application/json"

      response "200", "returns the list" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            position: { type: :integer },
            board_id: { type: :integer },
            created_at: { type: :string, format: "date-time" },
            updated_at: { type: :string, format: "date-time" }
          }

        run_test!
      end

      response "404", "list not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end

    put "Update a list" do
      tags "Lists"
      consumes "application/json"
      produces "application/json"

      parameter name: :list, in: :body, schema: {
        type: :object,
        properties: {
          list: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response "200", "list updated" do
        let(:list) { { list: { name: "Updated List" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("Updated List")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:list) { { list: { name: "" } } }

        run_test!
      end
    end

    delete "Delete a list" do
      tags "Lists"

      response "204", "list deleted" do
        run_test!
      end

      response "404", "list not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end
  end

  path "/api/v1/lists/{id}/move" do
    parameter name: :id, in: :path, type: :integer, description: "List ID"

    patch "Move a list to a new position" do
      tags "Lists"
      consumes "application/json"
      produces "application/json"

      parameter name: :list, in: :body, schema: {
        type: :object,
        properties: {
          list: {
            type: :object,
            properties: {
              position: { type: :integer, example: 2 }
            },
            required: %w[position]
          }
        }
      }

      response "200", "list moved" do
        let(:id) { create(:list, board: board).id }
        let(:list) { { list: { position: 1 } } }

        before { create_list(:list, 3, board: board) }

        run_test!
      end

      response "422", "invalid position" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:list, board: board).id }
        let(:list) { { list: { position: "" } } }

        run_test!
      end
    end
  end
end
