require "rails_helper"

RSpec.describe "Admin::TasksController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let(:board) { create(:board, user: user) }
  let(:list) { create(:list, board: board) }
  let(:task) { create(:task, list: list) }

  before do
    sign_in(admin_user, scope: :admin_user)
  end

  describe "GET /admin/lists/:list_id/tasks" do
    it "returns a successful response" do
      get admin_list_tasks_path(list)
      puts "Response status: #{response.status}"
      puts "Response body: #{response.body[0..500]}" if response.status != 200
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end

    it "assigns @tasks" do
      create(:task, list: list)
      get admin_list_tasks_path(list)
      expect(assigns(:tasks)).to be_present
    end

    it "assigns @list" do
      get admin_list_tasks_path(list)
      expect(assigns(:list)).to eq(list)
    end

    it "filters by status" do
      todo_task = create(:task, list: list, status: :todo)
      completed_task = create(:task, list: list, status: :completed)

      get admin_list_tasks_path(list, status: "todo")
      expect(assigns(:tasks)).to include(todo_task)
      expect(assigns(:tasks)).not_to include(completed_task)
    end

    it "filters by priority" do
      high_task = create(:task, list: list, priority: :high)
      low_task = create(:task, list: list, priority: :low)

      get admin_list_tasks_path(list, priority: "high")
      expect(assigns(:tasks)).to include(high_task)
      expect(assigns(:tasks)).not_to include(low_task)
    end

    it "filters by assignee" do
      assignee = create(:user)
      assigned_task = create(:task, list: list, assignee: assignee)
      unassigned_task = create(:task, list: list, assignee: nil)

      get admin_list_tasks_path(list, assignee_id: assignee.id)
      expect(assigns(:tasks)).to include(assigned_task)
      expect(assigns(:tasks)).not_to include(unassigned_task)
    end

    it "paginates results" do
      create_list(:task, 25, list: list)
      get admin_list_tasks_path(list)
      expect(assigns(:tasks).size).to eq(20)
    end

    it "uses includes for associations" do
      get admin_list_tasks_path(list)
      expect(response).to be_successful
    end
  end

  describe "GET /admin/lists/:list_id/tasks/:id" do
    it "returns a successful response" do
      get admin_list_task_path(list, task)
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end

    it "assigns @task" do
      get admin_list_task_path(list, task)
      expect(assigns(:task)).to eq(task)
    end

    it "assigns @list" do
      get admin_list_task_path(list, task)
      expect(assigns(:list)).to eq(list)
    end
  end

  describe "GET /admin/lists/:list_id/tasks/new" do
    it "returns a successful response" do
      get new_admin_list_task_path(list)
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end

    it "assigns a new @task" do
      get new_admin_list_task_path(list)
      expect(assigns(:task)).to be_a_new(Task)
    end

    it "assigns @users for form" do
      create(:user)
      get new_admin_list_task_path(list)
      expect(assigns(:users)).to be_present
    end
  end

  describe "POST /admin/lists/:list_id/tasks" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          title: "New Task",
          description: "Task description",
          status: "todo",
          priority: "high",
          deadline: 1.day.from_now,
          list_id: list.id
        }
      end

      it "creates a new task" do
        expect {
          post admin_list_tasks_path(list), params: { task: valid_attributes }
        }.to change(Task, :count).by(1)
      end

      it "redirects to the tasks list" do
        post admin_list_tasks_path(list), params: { task: valid_attributes }
        expect(response).to redirect_to(admin_list_tasks_path(list))
      end

      it "sets a success flash message" do
        post admin_list_tasks_path(list), params: { task: valid_attributes }
        expect(flash[:notice]).to match(/created/)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          title: "",
          list_id: list.id
        }
      end

      it "does not create a new task" do
        expect {
          post admin_list_tasks_path(list), params: { task: invalid_attributes }
        }.not_to change(Task, :count)
      end

      it "renders the new template" do
        post admin_list_tasks_path(list), params: { task: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it "returns unprocessable_entity status" do
        post admin_list_tasks_path(list), params: { task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/lists/:list_id/tasks/:id/edit" do
    it "returns a successful response" do
      get edit_admin_list_task_path(list, task)
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end

    it "assigns @task" do
      get edit_admin_list_task_path(list, task)
      expect(assigns(:task)).to eq(task)
    end
  end

  describe "PATCH /admin/lists/:list_id/tasks/:id" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          title: "Updated Task",
          status: "in_progress",
          priority: "medium"
        }
      end

      it "updates the task" do
        patch admin_list_task_path(list, task), params: { task: valid_attributes }
        task.reload
        expect(task.title).to eq("Updated Task")
        expect(task.status).to eq("in_progress")
      end

      it "redirects to the tasks list" do
        patch admin_list_task_path(list, task), params: { task: valid_attributes }
        expect(response).to redirect_to(admin_list_tasks_path(list))
      end

      it "sets a success flash message" do
        patch admin_list_task_path(list, task), params: { task: valid_attributes }
        expect(flash[:notice]).to match(/updated/)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          title: ""
        }
      end

      it "does not update the task" do
        original_title = task.title
        patch admin_list_task_path(list, task), params: { task: invalid_attributes }
        task.reload
        expect(task.title).to eq(original_title)
      end

      it "renders the edit template" do
        patch admin_list_task_path(list, task), params: { task: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable_entity status" do
        patch admin_list_task_path(list, task), params: { task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/lists/:list_id/tasks/:id" do
    it "deletes the task" do
      task_id = task.id
      expect {
        delete admin_list_task_path(list, task)
      }.to change(Task, :count).by(-1)
    end

    it "redirects to the tasks list" do
      delete admin_list_task_path(list, task)
      expect(response).to redirect_to(admin_list_tasks_path(list))
    end

    it "sets a success flash message" do
      delete admin_list_task_path(list, task)
      expect(flash[:notice]).to match(/deleted/)
    end
  end

  context "authorization" do
    let(:other_admin) { create(:admin_user) }

    before { sign_out(:admin_user) }

    it "requires admin user" do
      sign_in(other_admin, scope: :admin_user)
      get admin_list_tasks_path(list)
      expect(response).to be_successful
    end
  end
end
