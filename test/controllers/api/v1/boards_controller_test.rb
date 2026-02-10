require "test_helper"

class Api::V1::BoardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user ||= users(:one)
    @board_one = boards(:one)
  end

  # CRUD

  test "should get index" do
    get api_v1_boards_url, headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)["boards"]
    expected = @user.boards.count

    assert_equal expected, actual.length
  end

  test "should get show" do
    get api_v1_board_url(@board_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)
    expected = JSON.parse(BoardBlueprint.render(@board_one))

    assert_equal expected, actual
  end

  test "should create board with valid params" do
    assert_difference("@user.boards.count", 1) do
      post api_v1_boards_url,
           params: {
             board: {
               name: "New Board",
               description: "New Board Description",
               visibility: true,
               color: "#FFFFFF"
             }
           },
           headers: auth_headers_for(@user)
    end
    assert_response :success
  end

  test "should update board with valid params" do
    update_name = "Updated Board Name"

    put api_v1_board_url(@board_one, params: {
      board: { name: update_name }
    }), headers: auth_headers_for(@user)
    assert_response :success

    @board_one.reload
    actual = JSON.parse(response.body)

    assert_equal update_name, actual["name"]
  end

  test "should destroy board" do
    assert_difference("@user.boards.count", -1) do
      delete api_v1_board_url(@board_one), headers: auth_headers_for(@user)
    end

    assert_response :no_content
  end

  # Error cases
  test "should return 401 without auth headers" do
    get api_v1_boards_url
    assert_response :unauthorized
  end

  test "should return 422 for create with invalid params" do
    post api_v1_boards_url,
         params: {
           board: {
             name: "",
             description: "New Board Description",
             visibility: true,
             color: "#FFFFFF"
           }
         },
         headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 404 for show with invalid id" do
    get api_v1_board_url(id: "invalid"), headers: auth_headers_for(@user)
    assert_response :not_found
  end
end
