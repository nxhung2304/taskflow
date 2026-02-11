require "test_helper"

class Api::V1::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @list_one = lists(:one)
    @task_one = tasks(:one)
    @task_one_b = tasks(:one_b)

    @user_two = users(:two)
  end

  # === INDEX ===

  test "should get index" do
    get api_v1_list_tasks_url(@list_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)["tasks"]
    expected = @list_one.tasks.count

    assert_equal expected, actual.length
  end

  test "should return tasks ordered by position" do
    get api_v1_list_tasks_url(@list_one), headers: auth_headers_for(@user)
    assert_response :success

    tasks = JSON.parse(response.body)["tasks"]
    positions = tasks.map { |t| t["position"] }

    assert_equal positions, positions.sort
  end

  # === SHOW ===

  test "should get show" do
    get api_v1_task_url(@task_one), headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)
    expected = JSON.parse(TaskBlueprint.render(@task_one))

    assert_equal expected, actual
  end

  # === CREATE ===

  test "should create task with valid params" do
    assert_difference("@list_one.tasks.count", 1) do
      post api_v1_list_tasks_url(@list_one),
           params: {
             task: {
               title: "New Task",
               description: "Task description",
               priority: "high",
               deadline: 1.week.from_now.to_date.to_s
             }
           },
           headers: auth_headers_for(@user)
    end
    assert_response :created

    actual = JSON.parse(response.body)

    assert_equal "New Task", actual["title"]
    assert_equal "todo", actual["status"]
    assert_equal "high", actual["priority"]
  end

  test "should create task with default status todo" do
    post api_v1_list_tasks_url(@list_one),
         params: { task: { title: "Default Status Task" } },
         headers: auth_headers_for(@user)
    assert_response :created

    actual = JSON.parse(response.body)

    assert_equal "todo", actual["status"]
  end

  test "should create task with assignee" do
    post api_v1_list_tasks_url(@list_one),
         params: { task: { title: "Assigned Task", assignee_id: @user.id } },
         headers: auth_headers_for(@user)
    assert_response :created

    actual = JSON.parse(response.body)

    assert_equal @user.id, actual["assignee_id"]
  end

  # === UPDATE ===

  test "should update task with valid params" do
    patch api_v1_task_url(@task_one),
          params: { task: { title: "Updated Title", status: "in_progress" } },
          headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)

    assert_equal "Updated Title", actual["title"]
    assert_equal "in_progress", actual["status"]
  end

  test "should update task assignee" do
    patch api_v1_task_url(@task_one),
          params: { task: { assignee_id: @user_two.id } },
          headers: auth_headers_for(@user)
    assert_response :success

    actual = JSON.parse(response.body)

    assert_equal @user_two.id, actual["assignee_id"]
  end

  # === DESTROY ===

  test "should destroy task" do
    assert_difference("@list_one.tasks.count", -1) do
      delete api_v1_task_url(@task_one), headers: auth_headers_for(@user)
    end

    assert_response :no_content
  end

  # === MOVE ===

  test "should move task to new position" do
    patch move_api_v1_task_url(@task_one), params: {
      task: { position: 2 }
    }, headers: auth_headers_for(@user)
    assert_response :success

    @task_one.reload
    @task_one_b.reload

    assert_equal 2, @task_one.position
    assert_equal 1, @task_one_b.position
  end

  # === ERROR CASES ===

  test "should return 401 without auth headers" do
    get api_v1_list_tasks_url(@list_one)
    assert_response :unauthorized
  end

  test "should return 422 for create with blank title" do
    post api_v1_list_tasks_url(@list_one),
         params: { task: { title: "" } },
         headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 404 for show with invalid id" do
    get api_v1_task_url(id: 0), headers: auth_headers_for(@user)
    assert_response :not_found
  end

  test "should return 403 for task in another user board" do
    other_task = tasks(:two)

    get api_v1_task_url(other_task), headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for create in another user list" do
    other_list = lists(:two)

    post api_v1_list_tasks_url(other_list),
         params: { task: { title: "Hack" } },
         headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for update task in another user board" do
    other_task = tasks(:two)

    patch api_v1_task_url(other_task),
          params: { task: { title: "Hack" } },
          headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for destroy task in another user board" do
    other_task = tasks(:two)

    delete api_v1_task_url(other_task), headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  test "should return 403 for move task in another user board" do
    other_task = tasks(:two)

    patch move_api_v1_task_url(other_task), params: {
      task: { position: 1 }
    }, headers: auth_headers_for(@user)
    assert_response :forbidden
  end

  # === MOVE EDGE CASES ===

  test "should return 400 for move without position" do
    patch move_api_v1_task_url(@task_one), params: {
      task: {}
    }, headers: auth_headers_for(@user)
    assert_response 400
  end

  test "should return 422 for move with position 0" do
    patch move_api_v1_task_url(@task_one), params: {
      task: { position: 0 }
    }, headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 422 for move with negative position" do
    patch move_api_v1_task_url(@task_one), params: {
      task: { position: -1 }
    }, headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end

  test "should return 422 for move with alphabetic position" do
    patch move_api_v1_task_url(@task_one), params: {
      task: { position: "abc" }
    }, headers: auth_headers_for(@user)
    assert_response :unprocessable_entity
  end
end
