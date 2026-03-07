require "rails_helper"

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:board) { create(:board, user: user) }
  let(:other_board) { create(:board, user: other_user) }
  let(:list) { create(:list, board: board) }
  let(:other_list) { create(:list, board: other_board) }
  let(:task) { create(:task, list: list) }
  let(:other_task) { create(:task, list: other_list) }

  describe "GET /api/v1/lists/:list_id/tasks" do
    it "returns the list's tasks" do
      create_list(:task, 3, list: list)

      get api_v1_list_tasks_path(list), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["tasks"].length).to eq(3)
    end

    it "returns tasks ordered by position" do
      create_list(:task, 3, list: list)

      get api_v1_list_tasks_path(list), headers: auth_headers_for(user)

      positions = json["tasks"].map { |t| t["position"] }
      expect(positions).to eq(positions.sort)
    end

    context "filtering" do
      before do
        create(:task, list: list, status: :todo, priority: :medium)
        create(:task, list: list, status: :in_progress, priority: :high)
      end

      it "filters by status" do
        get api_v1_list_tasks_path(list), params: { status: "todo" }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["tasks"].length).to eq(1)
        expect(json["tasks"].all? { |t| t["status"] == "todo" }).to be true
      end

      it "filters by priority" do
        get api_v1_list_tasks_path(list), params: { priority: "high" }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["tasks"].length).to eq(1)
        expect(json["tasks"].all? { |t| t["priority"] == "high" }).to be true
      end

      it "filters by assignee_id" do
        assigned_task = create(:task, list: list, assignee_id: user.id)
        create(:task, list: list)

        get api_v1_list_tasks_path(list), params: { assignee_id: user.id }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["tasks"].length).to eq(1)
        expect(json["tasks"].first["id"]).to eq(assigned_task.id)
      end

      it "returns all tasks when filter value is invalid" do
        count = list.tasks.count

        get api_v1_list_tasks_path(list), params: { status: "banana" }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["tasks"].length).to eq(count)
      end

      it "supports combining multiple filters" do
        get api_v1_list_tasks_path(list),
            params: { status: "todo", priority: "medium" },
            headers: auth_headers_for(user)

        tasks = json["tasks"]
        expect(tasks.all? { |t| t["status"] == "todo" && t["priority"] == "medium" }).to be true
      end
    end

    it "returns 401 without auth" do
      get api_v1_list_tasks_path(list)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for another user's list" do
      get api_v1_list_tasks_path(other_list), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/tasks/:id" do
    it "returns the task" do
      get api_v1_task_path(task), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(task.id)
    end

    it "returns 404 for invalid id" do
      get api_v1_task_path(id: 0), headers: auth_headers_for(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 403 for another user's task" do
      get api_v1_task_path(other_task), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/lists/:list_id/tasks" do
    it "creates a task with valid params" do
      expect {
        post api_v1_list_tasks_path(list),
             params: { task: { title: "New Task", description: "Desc", priority: "high", deadline: 1.week.from_now.to_date.to_s } },
             headers: auth_headers_for(user)
      }.to change(list.tasks, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["title"]).to eq("New Task")
      expect(json["priority"]).to eq("high")
    end

    it "defaults status to todo" do
      post api_v1_list_tasks_path(list),
           params: { task: { title: "Task" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:created)
      expect(json["status"]).to eq("todo")
    end

    it "accepts an assignee" do
      post api_v1_list_tasks_path(list),
           params: { task: { title: "Task", assignee_id: user.id } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:created)
      expect(json["assignee_id"]).to eq(user.id)
    end

    it "returns 422 when title is blank" do
      post api_v1_list_tasks_path(list),
           params: { task: { title: "" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for invalid assignee_id" do
      post api_v1_list_tasks_path(list),
           params: { task: { title: "Task", assignee_id: 0 } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for past deadline" do
      post api_v1_list_tasks_path(list),
           params: { task: { title: "Task", deadline: 1.day.ago.to_date.to_s } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's list" do
      post api_v1_list_tasks_path(other_list),
           params: { task: { title: "Hack" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/tasks/:id" do
    it "updates the task" do
      patch api_v1_task_path(task),
            params: { task: { title: "Updated Title", status: "in_progress" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["title"]).to eq("Updated Title")
      expect(json["status"]).to eq("in_progress")
    end

    it "updates the assignee" do
      patch api_v1_task_path(task),
            params: { task: { assignee_id: other_user.id } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["assignee_id"]).to eq(other_user.id)
    end

    it "returns 422 for invalid status" do
      patch api_v1_task_path(task),
            params: { task: { status: "banana" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for invalid priority" do
      patch api_v1_task_path(task),
            params: { task: { priority: "banana" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's task" do
      patch api_v1_task_path(other_task),
            params: { task: { title: "Hack" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    it "destroys the task" do
      task_to_delete = create(:task, list: list)

      expect {
        delete api_v1_task_path(task_to_delete), headers: auth_headers_for(user)
      }.to change(list.tasks, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for another user's task" do
      delete api_v1_task_path(other_task), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/tasks/:id/move" do
    let!(:task_a) { create(:task, list: list) }
    let!(:task_b) { create(:task, list: list) }

    it "moves the task to the new position" do
      original_position = task_a.position

      patch move_api_v1_task_path(task_a),
            params: { task: { position: task_b.position } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(task_a.reload.position).not_to eq(original_position)
    end

    it "returns 400 when position is missing" do
      patch move_api_v1_task_path(task_a),
            params: { task: {} },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:bad_request)
    end

    it "returns 422 when position is 0" do
      patch move_api_v1_task_path(task_a),
            params: { task: { position: 0 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when position is negative" do
      patch move_api_v1_task_path(task_a),
            params: { task: { position: -1 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when position is non-numeric" do
      patch move_api_v1_task_path(task_a),
            params: { task: { position: "abc" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's task" do
      patch move_api_v1_task_path(other_task),
            params: { task: { position: 1 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
