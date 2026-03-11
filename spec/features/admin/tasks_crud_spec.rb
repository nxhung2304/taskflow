require "rails_helper"

feature "Admin Tasks CRUD", :js do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let(:board) { create(:board, user: user) }
  let(:list) { create(:list, board: board) }

  before do
    # Start the Rails server if not already running
    visit "http://localhost:3000/admin/admin_users/sign_in"

    fill_in "admin_user_email", with: admin_user.email
    fill_in "admin_user_password", with: admin_user.password

    # Find and click the submit button
    find('input[type="submit"]').click
  end

  scenario "Admin can view all tasks from dashboard" do
    create(:task, list: list, title: "Test Task 1")
    create(:task, list: list, title: "Test Task 2")

    visit admin_root_path
    expect(page).to have_content("Total Tasks")
    expect(page).to have_link("View All", href: admin_tasks_path)

    click_link "View All", match: :first
    expect(page).to have_current_path(admin_tasks_path)
    expect(page).to have_content("Test Task 1")
    expect(page).to have_content("Test Task 2")
  end

  scenario "Admin can view tasks from sidebar" do
    create(:task, list: list, title: "Sidebar Task")

    visit admin_root_path
    click_link "Tasks"

    expect(page).to have_current_path(admin_tasks_path)
    expect(page).to have_content("Sidebar Task")
  end

  scenario "Admin can view tasks for a specific list" do
    create(:task, list: list, title: "List Task 1")
    create(:task, list: list, title: "List Task 2")

    visit admin_list_tasks_path(list)

    expect(page).to have_content("List Task 1")
    expect(page).to have_content("List Task 2")
    expect(page).to have_breadcrumb(list.name)
  end

  scenario "Admin can create a new task" do
    visit admin_list_tasks_path(list)
    click_link "New Task"

    expect(page).to have_current_path(new_admin_list_task_path(list))

    fill_in "Title", with: "New Task Title"
    fill_in "Description", with: "Task description"
    select "in_progress", from: "Status"
    select "high", from: "Priority"
    click_button "Save"

    expect(page).to have_content("Task created successfully")
    expect(page).to have_content("New Task Title")
  end

  scenario "Admin can view task details" do
    assignee = create(:user)
    task = create(:task, list: list, title: "Detail Task",
                         status: :in_progress, priority: :high,
                         assignee: assignee)

    visit admin_list_task_path(list, task)

    expect(page).to have_content("Detail Task")
    expect(page).to have_content("In Progress")
    expect(page).to have_content("High")
    expect(page).to have_content(assignee.name)
    expect(page).to have_breadcrumb("Detail Task")
  end

  scenario "Admin can edit a task" do
    task = create(:task, list: list, title: "Original Title",
                         status: :todo, priority: :low)

    visit admin_list_task_path(list, task)
    click_link "Edit"

    expect(page).to have_current_path(edit_admin_list_task_path(list, task))

    fill_in "Title", with: "Updated Title"
    select "completed", from: "Status"
    select "medium", from: "Priority"
    click_button "Save"

    expect(page).to have_content("Task updated successfully")
    expect(page).to have_content("Updated Title")
  end

  scenario "Admin can filter tasks by status" do
    create(:task, list: list, title: "Todo Task", status: :todo)
    create(:task, list: list, title: "In Progress Task", status: :in_progress)

    visit admin_list_tasks_path(list)
    select "todo", from: "Status"

    expect(page).to have_content("Todo Task")
    expect(page).not_to have_content("In Progress Task")
  end

  scenario "Admin can filter tasks by priority" do
    create(:task, list: list, title: "High Priority", priority: :high)
    create(:task, list: list, title: "Low Priority", priority: :low)

    visit admin_list_tasks_path(list)
    select "high", from: "Priority"

    expect(page).to have_content("High Priority")
    expect(page).not_to have_content("Low Priority")
  end

  scenario "Admin can filter tasks by assignee" do
    assignee = create(:user)
    create(:task, list: list, title: "Assigned Task", assignee: assignee)
    create(:task, list: list, title: "Unassigned Task", assignee: nil)

    visit admin_list_tasks_path(list)
    select assignee.name, from: "Assigned To"

    expect(page).to have_content("Assigned Task")
    expect(page).not_to have_content("Unassigned Task")
  end

  scenario "Admin can delete a task" do
    task = create(:task, list: list, title: "Task to Delete")

    visit admin_list_task_path(list, task)

    page.accept_confirm do
      click_link "Delete"
    end

    expect(page).to have_content("Task deleted successfully")
    expect(page).not_to have_content("Task to Delete")
  end

  scenario "Admin sees validation errors when creating task without title" do
    visit admin_list_tasks_path(list)
    click_link "New Task"

    click_button "Save"

    expect(page).to have_content("error")
    expect(page).to have_content("Title")
  end

  scenario "Admin can search tasks by title" do
    create(:task, list: list, title: "Ruby Task")
    create(:task, list: list, title: "JavaScript Task")

    visit admin_list_tasks_path(list)
    fill_in "Search by title...", with: "Ruby"
    find("input[placeholder='Search by title...']").native.send_keys(:enter)

    expect(page).to have_content("Ruby Task")
    expect(page).not_to have_content("JavaScript Task")
  end

  scenario "Admin can view task comments" do
    task = create(:task, list: list, title: "Task with Comments")
    comment_user = create(:user)
    create(:comment, task: task, user: comment_user, content: "Test comment")

    visit admin_list_task_path(list, task)

    expect(page).to have_content("Comments")
    expect(page).to have_content("Test comment")
    expect(page).to have_content(comment_user.name)
  end

  scenario "Admin can see task metadata" do
    task = create(:task, list: list, title: "Metadata Task")

    visit admin_list_task_path(list, task)

    expect(page).to have_content("List:")
    expect(page).to have_content(list.name)
    expect(page).to have_content("Board:")
    expect(page).to have_content(board.name)
    expect(page).to have_content("Created:")
    expect(page).to have_content("Updated:")
  end

  def have_breadcrumb(text)
    have_content(text)
  end
end
