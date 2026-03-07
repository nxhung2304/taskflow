require "rails_helper"

RSpec.describe "Api::V1::Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:board) { create(:board, user: user) }
  let(:other_board) { create(:board, user: other_user) }
  let(:list) { create(:list, board: board) }
  let(:task) { create(:task, list: list) }
  let(:other_task) { create(:task, list: create(:list, board: other_board)) }
  let(:comment) { create(:comment, task: task, user: user) }
  let(:other_comment) { create(:comment, task: other_task, user: other_user) }

  describe "GET /api/v1/tasks/:task_id/comments" do
    it "returns the task's comments" do
      create_list(:comment, 3, task: task, user: user)

      get api_v1_task_comments_path(task), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["comments"].length).to eq(3)
    end

    it "returns comments ordered by created_at asc" do
      create(:comment, task: task, user: user, created_at: 2.days.ago)
      create(:comment, task: task, user: user, created_at: 1.day.ago)

      get api_v1_task_comments_path(task), headers: auth_headers_for(user)

      timestamps = json["comments"].map { |c| c["created_at"] }
      expect(timestamps).to eq(timestamps.sort)
    end

    it "returns 401 without auth" do
      get api_v1_task_comments_path(task)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for another user's task" do
      get api_v1_task_comments_path(other_task), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/comments/:id" do
    it "returns the comment with author" do
      get api_v1_comment_path(comment), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(comment.id)
      expect(json["content"]).to eq(comment.content)
    end

    it "returns 404 for invalid id" do
      get api_v1_comment_path(id: 0), headers: auth_headers_for(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 403 for comment in another user's board" do
      get api_v1_comment_path(other_comment), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/tasks/:task_id/comments" do
    it "creates a comment" do
      expect {
        post api_v1_task_comments_path(task),
             params: { comment: { content: "New comment" } },
             headers: auth_headers_for(user)
      }.to change(task.comments, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["content"]).to eq("New comment")
    end

    it "assigns the current user as author" do
      post api_v1_task_comments_path(task),
           params: { comment: { content: "My comment" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:created)
      expect(Comment.last.user_id).to eq(user.id)
    end

    it "increments task comments_count" do
      expect {
        post api_v1_task_comments_path(task),
             params: { comment: { content: "Counter test" } },
             headers: auth_headers_for(user)
      }.to change { task.reload.comments_count }.by(1)
    end

    it "returns 422 when content is blank" do
      post api_v1_task_comments_path(task),
           params: { comment: { content: "" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when content exceeds 500 characters" do
      post api_v1_task_comments_path(task),
           params: { comment: { content: "a" * 501 } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's task" do
      post api_v1_task_comments_path(other_task),
           params: { comment: { content: "Hack" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/comments/:id" do
    it "updates the comment" do
      patch api_v1_comment_path(comment),
            params: { comment: { content: "Updated content" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["content"]).to eq("Updated content")
    end

    it "returns 422 when content is blank" do
      patch api_v1_comment_path(comment),
            params: { comment: { content: "" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's comment" do
      patch api_v1_comment_path(other_comment),
            params: { comment: { content: "Hack" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/comments/:id" do
    it "destroys the comment" do
      comment_to_delete = create(:comment, task: task, user: user)

      expect {
        delete api_v1_comment_path(comment_to_delete), headers: auth_headers_for(user)
      }.to change(task.comments, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "decrements task comments_count" do
      comment_to_delete = create(:comment, task: task, user: user)

      expect {
        delete api_v1_comment_path(comment_to_delete), headers: auth_headers_for(user)
      }.to change { task.reload.comments_count }.by(-1)
    end

    it "returns 403 for another user's comment" do
      delete api_v1_comment_path(other_comment), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
