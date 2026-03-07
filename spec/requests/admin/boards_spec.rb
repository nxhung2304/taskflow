require "rails_helper"

RSpec.describe "Admin::Boards", type: :request do
  let(:admin_user) { create(:admin_user, password: "password123") }
  let(:user) { create(:user) }
  let(:board) { create(:board, user:) }

  before { sign_in_admin admin_user }

  describe "GET /admin/boards" do
    it "returns 200 and lists all boards" do
      create(:board, user:)
      get admin_boards_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Boards")
    end

    context "with search by name" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        create(:board, name: "Project Alpha", user: user1)
        create(:board, name: "Project Beta", user: user2)
        create(:board, name: "Client Gamma", user: user1)
      end

      it "filters boards by name" do
        get admin_boards_path(search: "Project")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Project Alpha")
        expect(response.body).to include("Project Beta")
        expect(response.body).not_to include("Client Gamma")
      end

      it "filters boards by name (case insensitive)" do
        get admin_boards_path(search: "project")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Project Alpha")
        expect(response.body).to include("Project Beta")
      end

      it "returns empty results when no boards match" do
        get admin_boards_path(search: "NonExistent")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No Boards Found")
      end
    end

    context "with filter by user" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        create(:board, name: "Board 1", user: user1)
        create(:board, name: "Board 2", user: user1)
        create(:board, name: "Board 3", user: user2)
      end

      it "filters boards by user" do
        get admin_boards_path(user_id: user1.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Board 1")
        expect(response.body).to include("Board 2")
        expect(response.body).not_to include("Board 3")
      end
    end

    context "with combined search and filter" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        create(:board, name: "Project Alpha", user: user1)
        create(:board, name: "Project Beta", user: user2)
        create(:board, name: "Client Alpha", user: user1)
      end

      it "applies both search and filter together" do
        get admin_boards_path(search: "Project", user_id: user1.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Project Alpha")
        expect(response.body).not_to include("Project Beta")
        expect(response.body).not_to include("Client Alpha")
      end
    end
  end

  describe "GET /admin/boards/new" do
    it "returns 200 and renders the new form" do
      get new_admin_board_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Board Name")
      expect(response.body).to include("Owner")
    end
  end

  describe "POST /admin/boards" do
    context "with valid params" do
      let(:valid_params) do
        {
          board: {
            name: "New Board",
            description: "Test board",
            user_id: user.id,
            color: "#FF0000",
            visibility: true
          }
        }
      end

      it "creates a board and redirects to index" do
        expect {
          post admin_boards_path, params: valid_params
        }.to change(Board, :count).by(1)

        expect(response).to redirect_to(admin_boards_path)
        follow_redirect!
        expect(response.body).to include("Board was successfully created.")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          board: {
            name: "",
            user_id: user.id
          }
        }
      end

      it "does not create a board and renders new" do
        expect {
          post admin_boards_path, params: invalid_params
        }.not_to change(Board, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/boards/:id" do
    it "returns 200 and displays the board" do
      get admin_board_path(board)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(board.name)
      expect(response.body).to include(user.name)
    end
  end

  describe "GET /admin/boards/:id/edit" do
    it "returns 200 and renders the edit form" do
      get edit_admin_board_path(board)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit Board")
      expect(response.body).to include(board.name)
    end
  end

  describe "PATCH /admin/boards/:id" do
    context "with valid params" do
      let(:update_params) do
        {
          board: {
            name: "Updated Board Name",
            description: "Updated description"
          }
        }
      end

      it "updates the board and redirects to index" do
        patch admin_board_path(board), params: update_params
        expect(response).to redirect_to(admin_boards_path)

        board.reload
        expect(board.name).to eq("Updated Board Name")
        expect(board.description).to eq("Updated description")

        follow_redirect!
        expect(response.body).to include("Board was successfully updated.")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          board: {
            name: ""
          }
        }
      end

      it "does not update the board and renders edit" do
        original_name = board.name
        patch admin_board_path(board), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(board.reload.name).to eq(original_name)
      end
    end
  end

  describe "DELETE /admin/boards/:id" do
    it "deletes the board and redirects to index" do
      board_id = board.id
      expect {
        delete admin_board_path(board)
      }.to change(Board, :count).by(-1)

      expect(response).to redirect_to(admin_boards_path)
      expect(Board.exists?(board_id)).to be false

      follow_redirect!
      expect(response.body).to include("Board was successfully destroyed.")
    end
  end
end
