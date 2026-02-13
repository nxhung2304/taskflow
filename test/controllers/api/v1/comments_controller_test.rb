require "test_helper"

class Api::V1::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @task_one = tasks(:one)
    @comment_one = comments(:one)

    @user_two = users(:two)
  end

  # === INDEX ===

  test "should get index" do
    get api_v1_task_comments_url(@task_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)["comments"]
    expected = @task_one.comments.count

    assert_equal expected, actual.length
  end

  test "should return comments ordered by created_at asc" do
    @task_one.comments.create!(content: "Older comment", user: @user, created_at: 2.days.ago)
    @task_one.comments.create!(content: "Newer comment", user: @user, created_at: 1.day.ago)

    get api_v1_task_comments_url(@task_one), headers: auth_headers_for(@user)
    assert_response :success

    comments = JSON.parse(response.body)["comments"]
    timestamps = comments.map { |c| c["created_at"] }

    assert_equal timestamps, timestamps.sort
  end

  # === SHOW ===

  test "should get show" do
    get api_v1_comment_url(@comment_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)
    expected = JSON.parse(CommentBlueprint.render(@comment_one, view: :with_author))

    assert_equal expected, actual
  end

  # === CREATE ===

  test "should create comment with valid params" do
    assert_difference("@task_one.comments.count", 1) do
      post api_v1_task_comments_url(@task_one),
           params: { comment: { content: "New comment" } },
           headers: auth_headers_for(@user)
    end
    assert_response :created

    actual = JSON.parse(response.body)

    assert_equal "New comment", actual["content"]
  end

  test "should assign current user as comment author" do
    post api_v1_task_comments_url(@task_one),
         params: { comment: { content: "My comment" } },
         headers: auth_headers_for(@user)
    assert_response :created

    comment = Comment.last

    assert_equal @user.id, comment.user_id
  end

  test "should increment task comments_count on create" do
    assert_difference("@task_one.reload.comments_count", 1) do
      post api_v1_task_comments_url(@task_one),
           params: { comment: { content: "Counter test" } },
           headers: auth_headers_for(@user)
    end
  end

  # === UPDATE ===

  test "should update comment with valid params" do
    patch api_v1_comment_url(@comment_one),
          params: { comment: { content: "Updated content" } },
          headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)

    assert_equal "Updated content", actual["content"]
  end

  # === DESTROY ===

  test "should destroy comment" do
    assert_difference("@task_one.comments.count", -1) do
      delete api_v1_comment_url(@comment_one), headers: auth_headers_for(@user)
    end

    assert_response :no_content
  end

  test "should decrement task comments_count on destroy" do
    assert_difference("@task_one.reload.comments_count", -1) do
      delete api_v1_comment_url(@comment_one), headers: auth_headers_for(@user)
    end
  end

  # === VALIDATION EDGE CASES ===

  test "should return 422 for create with blank content" do
    post api_v1_task_comments_url(@task_one),
         params: { comment: { content: "" } },
         headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 422 for create with content exceeding 500 characters" do
    post api_v1_task_comments_url(@task_one),
         params: { comment: { content: "a" * 501 } },
         headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 422 for update with blank content" do
    patch api_v1_comment_url(@comment_one),
          params: { comment: { content: "" } },
          headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  # === ERROR CASES ===

  test "should return 401 without auth headers" do
    get api_v1_task_comments_url(@task_one)
    assert_response :unauthorized
  end

  test "should return 404 for show with invalid id" do
    get api_v1_comment_url(id: 0), headers: auth_headers_for(@user)
    assert_response :not_found
  end

  test "should return 403 for index on another user task" do
    other_task = tasks(:two)

    get api_v1_task_comments_url(other_task), headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for create on another user task" do
    other_task = tasks(:two)

    post api_v1_task_comments_url(other_task),
         params: { comment: { content: "Hack" } },
         headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for show comment in another user board" do
    other_comment = comments(:two)

    get api_v1_comment_url(other_comment), headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for update comment in another user board" do
    other_comment = comments(:two)

    patch api_v1_comment_url(other_comment),
          params: { comment: { content: "Hack" } },
          headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for destroy comment in another user board" do
    other_comment = comments(:two)

    delete api_v1_comment_url(other_comment), headers: auth_headers_for(@user)
    assert_response :forbidden
  end
end
