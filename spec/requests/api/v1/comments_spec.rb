require "swagger_helper"

RSpec.describe "Comments API", type: :request do
  include_context "authenticated user"

  let(:board) { create(:board, user: user) }
  let(:list) { create(:list, board: board) }
  let(:task) { create(:task, list: list) }

  path "/api/v1/tasks/{task_id}/comments" do
    parameter name: :task_id, in: :path, type: :integer, description: "Task ID"
    let(:task_id) { task.id }

    get "List all comments for a task" do
      tags "Comments"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"

      response "200", "returns comments" do
        schema type: :object,
          properties: {
            comments: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  content: { type: :string },
                  task_id: { type: :integer },
                  user_id: { type: :integer },
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

        before { create_list(:comment, 3, task: task, user: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["comments"].size).to eq(3)
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

    post "Create a comment" do
      tags "Comments"
      consumes "application/json"
      produces "application/json"

      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              content: { type: :string, example: "Great progress on this task!" }
            },
            required: %w[content]
          }
        }
      }

      response "201", "comment created" do
        let(:comment) { { comment: { content: "This looks great!" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["content"]).to eq("This looks great!")
          expect(data["user_id"]).to eq(user.id)
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:comment) { { comment: { content: "" } } }

        run_test!
      end
    end
  end

  path "/api/v1/comments/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Comment ID"
    let(:existing_comment) { create(:comment, task: task, user: user) }
    let(:id) { existing_comment.id }

    get "Show a comment" do
      tags "Comments"
      produces "application/json"

      response "200", "returns the comment with author" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            content: { type: :string },
            task_id: { type: :integer },
            user_id: { type: :integer },
            author: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
                image: { type: :string, nullable: true }
              }
            },
            created_at: { type: :string, format: "date-time" },
            updated_at: { type: :string, format: "date-time" }
          }

        run_test!
      end

      response "404", "comment not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end

    put "Update a comment" do
      tags "Comments"
      consumes "application/json"
      produces "application/json"

      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              content: { type: :string }
            }
          }
        }
      }

      response "200", "comment updated" do
        let(:comment) { { comment: { content: "Updated comment" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["content"]).to eq("Updated comment")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:comment) { { comment: { content: "" } } }

        run_test!
      end
    end

    delete "Delete a comment" do
      tags "Comments"

      response "204", "comment deleted" do
        run_test!
      end

      response "404", "comment not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
