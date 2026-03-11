require "rails_helper"

RSpec.describe "Admin::Lists", type: :request do
  let(:admin_user) { create(:admin_user, password: "password123") }
  let(:user) { create(:user) }
  let(:board) { create(:board, user:) }
  let(:list) { create(:list, board:) }

  before { sign_in_admin admin_user }

  describe "GET /admin/lists" do
    it "returns 200 and lists all lists from all boards" do
      user2 = create(:user)
      board2 = create(:board, user: user2)
      list1 = create(:list, name: "Todo", board:)
      list2 = create(:list, name: "In Progress", board: board2)

      get admin_lists_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lists Management")
      expect(response.body).to include("Todo")
      expect(response.body).to include("In Progress")
      expect(response.body).to include(board.name)
      expect(response.body).to include(board2.name)
    end

    context "with board filter" do
      before do
        user2 = create(:user)
        @board2 = create(:board, user: user2)
        create(:list, name: "Todo", board:)
        create(:list, name: "Doing", board:)
        create(:list, name: "Done", board: @board2)
      end

      it "filters lists by board" do
        get admin_lists_path(filter_board_id: board.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Todo")
        expect(response.body).to include("Doing")
        expect(response.body).not_to include("Done")
      end

      it "shows all lists when no board filter is applied" do
        get admin_lists_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Todo")
        expect(response.body).to include("Doing")
        expect(response.body).to include("Done")
      end
    end

    describe "POST /admin/lists (global)" do
      context "with valid params" do
        it "creates a list and redirects to index" do
          expect {
            post admin_lists_path, params: {
              list: {
                name: "Global List",
                board_id: board.id
              }
            }
          }.to change(List, :count).by(1)

          expect(response).to redirect_to(admin_lists_path)
        end
      end
    end

    describe "PATCH /admin/lists/:id (global)" do
      it "updates the list and redirects to index" do
        patch admin_list_path(list), params: {
          list: {
            name: "Updated Global List"
          }
        }
        expect(response).to redirect_to(admin_lists_path)
        expect(list.reload.name).to eq("Updated Global List")
      end
    end

    describe "DELETE /admin/lists/:id (global)" do
      it "deletes the list and redirects to index" do
        list_id = list.id
        expect {
          delete admin_list_path(list)
        }.to change(List, :count).by(-1)

        expect(response).to redirect_to(admin_lists_path)
      end
    end
  end

  describe "GET /admin/boards/:board_id/lists" do
    it "returns 200 and lists all lists for the board" do
      create(:list, board:)
      get admin_board_lists_path(board)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lists Management")
    end

    context "with search by name" do
      before do
        create(:list, name: "Todo", board:)
        create(:list, name: "In Progress", board:)
        create(:list, name: "Done", board:)
      end

      it "filters lists by name" do
        get admin_board_lists_path(board, search: "Todo")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Todo")
        expect(response.body).not_to include("In Progress")
      end

      it "filters lists by name (case insensitive)" do
        get admin_board_lists_path(board, search: "todo")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Todo")
      end

      it "returns empty results when no lists match" do
        get admin_board_lists_path(board, search: "NonExistent")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No Lists Found")
      end
    end
  end

  describe "GET /admin/boards/:board_id/lists/new" do
    it "returns 200 and renders the new form" do
      get new_admin_board_list_path(board)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("List Name")
    end
  end

  describe "POST /admin/boards/:board_id/lists" do
    context "with valid params" do
      let(:valid_params) do
        {
          list: {
            name: "New List"
          }
        }
      end

      it "creates a list and redirects to index" do
        expect {
          post admin_board_lists_path(board), params: valid_params
        }.to change(List, :count).by(1)

        expect(response).to redirect_to(admin_board_lists_path(board))
        follow_redirect!
        expect(response.body).to include("List was successfully created.")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          list: {
            name: ""
          }
        }
      end

      it "does not create a list and renders new" do
        expect {
          post admin_board_lists_path(board), params: invalid_params
        }.not_to change(List, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays error messages" do
        post admin_board_lists_path(board), params: invalid_params
        expect(response.body).to include("prevented this list from being saved")
      end
    end
  end

  describe "GET /admin/boards/:board_id/lists/:id" do
    it "returns 200 and displays the list" do
      get admin_board_list_path(board, list)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(list.name)
    end
  end

  describe "GET /admin/boards/:board_id/lists/:id/edit" do
    it "returns 200 and renders the edit form" do
      get edit_admin_board_list_path(board, list)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit List")
      expect(response.body).to include(list.name)
    end
  end

  describe "PATCH /admin/boards/:board_id/lists/:id" do
    context "with valid params" do
      let(:update_params) do
        {
          list: {
            name: "Updated List Name"
          }
        }
      end

      it "updates the list and redirects to index" do
        patch admin_board_list_path(board, list), params: update_params
        expect(response).to redirect_to(admin_board_lists_path(board))

        list.reload
        expect(list.name).to eq("Updated List Name")

        follow_redirect!
        expect(response.body).to include("List was successfully updated.")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          list: {
            name: ""
          }
        }
      end

      it "does not update the list and renders edit" do
        original_name = list.name
        patch admin_board_list_path(board, list), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(list.reload.name).to eq(original_name)
      end
    end
  end

  describe "DELETE /admin/boards/:board_id/lists/:id" do
    it "deletes the list and redirects to index" do
      list_id = list.id
      expect {
        delete admin_board_list_path(board, list)
      }.to change(List, :count).by(-1)

      expect(response).to redirect_to(admin_board_lists_path(board))
      expect(List.exists?(list_id)).to be false

      follow_redirect!
      expect(response.body).to include("List was successfully destroyed.")
    end
  end
end
