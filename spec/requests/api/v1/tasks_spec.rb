require "swagger_helper"

RSpec.describe "Tasks API", type: :request do
  include_context "authenticated user"

  let(:board) { create(:board, user: user) }
  let(:existing_list) { create(:list, board: board) }

  path "/api/v1/lists/{list_id}/tasks" do
    parameter name: :list_id, in: :path, type: :integer, description: "List ID"
    let(:list_id) { existing_list.id }

    get "List all tasks in a list" do
      tags "Tasks"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"
      parameter name: :status, in: :query, type: :string, required: false,
        enum: %w[todo in_progress completed], description: "Filter by status"
      parameter name: :priority, in: :query, type: :string, required: false,
        enum: %w[low medium high], description: "Filter by priority"
      parameter name: :assignee_id, in: :query, type: :integer, required: false,
        description: "Filter by assignee ID"

      response "200", "returns tasks" do
        schema type: :object,
          properties: {
            tasks: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string },
                  description: { type: :string, nullable: true },
                  position: { type: :integer },
                  priority: { type: :string, nullable: true },
                  deadline: { type: :string, format: "date-time", nullable: true },
                  status: { type: :string },
                  list_id: { type: :integer },
                  assignee_id: { type: :integer, nullable: true },
                  comments_count: { type: :integer },
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

        before { create_list(:task, 3, list: existing_list) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["tasks"].size).to eq(3)
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

    post "Create a task" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string, example: "Implement login" },
              description: { type: :string, example: "Add JWT authentication" },
              priority: { type: :string, enum: %w[low medium high], example: "medium" },
              deadline: { type: :string, format: "date-time", example: "2026-12-31T23:59:59Z" },
              status: { type: :string, enum: %w[todo in_progress completed], example: "todo" },
              assignee_id: { type: :integer, nullable: true }
            },
            required: %w[title]
          }
        }
      }

      response "201", "task created" do
        let(:task) { { task: { title: "New Task", description: "Task description", priority: "high" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("New Task")
          expect(data["priority"]).to eq("high")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:task) { { task: { title: "" } } }

        run_test!
      end
    end
  end

  path "/api/v1/tasks/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Task ID"
    let(:existing_task) { create(:task, list: existing_list) }
    let(:id) { existing_task.id }

    get "Show a task" do
      tags "Tasks"
      produces "application/json"

      response "200", "returns the task" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            description: { type: :string, nullable: true },
            position: { type: :integer },
            priority: { type: :string, nullable: true },
            deadline: { type: :string, format: "date-time", nullable: true },
            status: { type: :string },
            list_id: { type: :integer },
            assignee_id: { type: :integer, nullable: true },
            comments_count: { type: :integer },
            created_at: { type: :string, format: "date-time" },
            updated_at: { type: :string, format: "date-time" }
          }

        run_test!
      end

      response "404", "task not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end

    put "Update a task" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              priority: { type: :string, enum: %w[low medium high] },
              deadline: { type: :string, format: "date-time" },
              status: { type: :string, enum: %w[todo in_progress completed] },
              assignee_id: { type: :integer, nullable: true }
            }
          }
        }
      }

      response "200", "task updated" do
        let(:task) { { task: { title: "Updated Task", status: "in_progress" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("Updated Task")
          expect(data["status"]).to eq("in_progress")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/errors"

        let(:task) { { task: { title: "" } } }

        run_test!
      end
    end

    delete "Delete a task" do
      tags "Tasks"

      response "204", "task deleted" do
        run_test!
      end

      response "404", "task not found" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { 0 }

        run_test!
      end
    end
  end

  path "/api/v1/tasks/{id}/move" do
    parameter name: :id, in: :path, type: :integer, description: "Task ID"

    patch "Move a task to a new position" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              position: { type: :integer, example: 2 }
            },
            required: %w[position]
          }
        }
      }

      response "200", "task moved" do
        let(:id) { create(:task, list: existing_list).id }
        let(:task) { { task: { position: 1 } } }

        before { create_list(:task, 3, list: existing_list) }

        run_test!
      end

      response "422", "invalid position" do
        schema "$ref" => "#/components/schemas/errors"

        let(:id) { create(:task, list: existing_list).id }
        let(:task) { { task: { position: "" } } }

        run_test!
      end
    end
  end
end
