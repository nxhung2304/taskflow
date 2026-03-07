require "rails_helper"

RSpec.describe "Api::V1::Lists", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:board) { create(:board, user: user) }
  let(:other_board) { create(:board, user: other_user) }
  let(:list) { create(:list, board: board) }
  let(:other_list) { create(:list, board: other_board) }

  describe "GET /api/v1/boards/:board_id/lists" do
    it "returns the board's lists" do
      create_list(:list, 3, board: board)

      get api_v1_board_lists_path(board), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["lists"].length).to eq(3)
    end

    it "returns 401 without auth" do
      get api_v1_board_lists_path(board)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/lists/:id" do
    it "returns the list" do
      get api_v1_list_path(list), headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(list.id)
    end

    it "returns 404 for invalid id" do
      get api_v1_list_path(id: 0), headers: auth_headers_for(user)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 403 for another user's list" do
      get api_v1_list_path(other_list), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/boards/:board_id/lists" do
    it "creates a list" do
      expect {
        post api_v1_board_lists_path(board),
             params: { list: { name: "New List" } },
             headers: auth_headers_for(user)
      }.to change(board.lists, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "returns 422 when name is blank" do
      post api_v1_board_lists_path(board),
           params: { list: { name: "" } },
           headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 401 without auth" do
      post api_v1_board_lists_path(board), params: { list: { name: "List" } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /api/v1/lists/:id" do
    it "updates the list" do
      put api_v1_list_path(list),
          params: { list: { name: "Updated Name" } },
          headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Updated Name")
    end

    it "returns 422 when name is blank" do
      put api_v1_list_path(list),
          params: { list: { name: "" } },
          headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/lists/:id" do
    it "destroys the list" do
      list_to_delete = create(:list, board: board)

      expect {
        delete api_v1_list_path(list_to_delete), headers: auth_headers_for(user)
      }.to change(board.lists, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for another user's list" do
      delete api_v1_list_path(other_list), headers: auth_headers_for(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/lists/:id/move" do
    let!(:list_a) { create(:list, board: board) }
    let!(:list_b) { create(:list, board: board) }

    it "moves the list to the new position" do
      original_position = list_a.position

      patch move_api_v1_list_path(list_a),
            params: { list: { position: list_b.position } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      expect(list_a.reload.position).not_to eq(original_position)
    end

    it "returns 400 when position is missing" do
      patch move_api_v1_list_path(list_a),
            params: { list: {} },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:bad_request)
    end

    it "returns 422 when position is 0" do
      patch move_api_v1_list_path(list_a),
            params: { list: { position: 0 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when position is negative" do
      patch move_api_v1_list_path(list_a),
            params: { list: { position: -1 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when position is non-numeric" do
      patch move_api_v1_list_path(list_a),
            params: { list: { position: "abc" } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for another user's list" do
      patch move_api_v1_list_path(other_list),
            params: { list: { position: 1 } },
            headers: auth_headers_for(user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
