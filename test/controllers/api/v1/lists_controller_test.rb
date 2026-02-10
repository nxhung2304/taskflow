require "test_helper"

class Api::V1::ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user ||= users(:one)
    @board_one = boards(:one)
    @list_one = lists(:one)

    @user_two = users(:two)
  end

  test "should get index" do
    get api_v1_board_lists_url(@board_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)["lists"]
    expected = @board_one.lists.count

    assert_equal expected, actual.length
  end

  test "should get show" do
    get api_v1_list_url(@list_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)
    expected = JSON.parse(ListBlueprint.render(@list_one))

    assert_equal expected, actual
  end

  test "should create list with valid params" do
    assert_difference("@board_one.lists.count", 1) do
      post api_v1_board_lists_url(@board_one),
           params: {
             list: {
               name: "New List"
             }
           },
           headers: auth_headers_for(@user)
    end
    assert_response :created
  end

  test "should update list with valid params" do
    update_name = "Updated List Name"

    put api_v1_list_url(@list_one, params: {
      list: { name: update_name }
    }), headers: auth_headers_for(@user)
    assert_response :success

    @list_one.reload
    actual = JSON.parse(response.body)

    assert_equal update_name, actual["name"]
  end

  test "should destroy list" do
    assert_difference("@board_one.lists.count", -1) do
      delete api_v1_list_url(@list_one), headers: auth_headers_for(@user)
    end

    assert_response :no_content
  end

  # Error cases
  test "should return 401 without auth headers" do
    get api_v1_board_lists_url(@board_one)
    assert_response :unauthorized
  end

  test "should return 422 for create with invalid params" do
    post api_v1_board_lists_url(@board_one),
         params: {
           list: {
             name: ""
           }
         },
         headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 404 for show with invalid id" do
    get api_v1_list_url(@board_one, id: "invalid"), headers: auth_headers_for(@user)
    assert_response :not_found
  end

  test "should return 403 for list in another user board" do
    other_list = lists(:two)

    get api_v1_list_url(other_list), headers: auth_headers_for(@user)
    assert_response :forbidden
  end
end
