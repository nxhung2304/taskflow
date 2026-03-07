require "rails_helper"

RSpec.describe "Api::V1::Boards", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:board) { create(:board, user: user) }

  describe "GET /api/v1/boards" do
    context "when authenticated" do
      it "returns only the current user's boards" do
        create_list(:board, 2, user: user)
        create(:board, user: other_user)

        get api_v1_boards_path, headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["boards"].length).to eq(2)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get api_v1_boards_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/boards/:id" do
    context "when authenticated" do
      it "returns the board" do
        get api_v1_board_path(board), headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(board.id)
      end

      it "returns 404 for invalid id" do
        get api_v1_board_path(id: 0), headers: auth_headers_for(user)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/boards" do
    context "with valid params" do
      it "creates a board and returns it" do
        expect {
          post api_v1_boards_path,
               params: { board: { name: "New Board", description: "Desc", visibility: true, color: "#FFFFFF" } },
               headers: auth_headers_for(user)
        }.to change(user.boards, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "returns 422 when name is blank" do
        post api_v1_boards_path,
             params: { board: { name: "" } },
             headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post api_v1_boards_path, params: { board: { name: "Board" } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/boards/:id" do
    context "with valid params" do
      it "updates the board" do
        put api_v1_board_path(board),
            params: { board: { name: "Updated Name" } },
            headers: auth_headers_for(user)

        expect(response).to have_http_status(:ok)
        expect(json["name"]).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "returns 422 when name is blank" do
        put api_v1_board_path(board),
            params: { board: { name: "" } },
            headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/boards/:id" do
    it "destroys the board" do
      board_to_delete = create(:board, user: user)

      expect {
        delete api_v1_board_path(board_to_delete), headers: auth_headers_for(user)
      }.to change(user.boards, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for another user's board" do
      other_board = create(:board, user: other_user)

      delete api_v1_board_path(other_board), headers: auth_headers_for(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  def json
    JSON.parse(response.body)
  end
end
