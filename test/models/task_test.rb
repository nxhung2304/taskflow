# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  deadline    :datetime
#  description :text
#  position    :integer          default(0), not null
#  priority    :integer
#  status      :integer          default("todo"), not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assignee_id :bigint
#  list_id     :bigint           not null
#
# Indexes
#
#  index_tasks_on_assignee_id  (assignee_id)
#  index_tasks_on_list_id      (list_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignee_id => users.id)
#  fk_rails_...  (list_id => lists.id)
#

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:one)
  end

  context "associations" do
    should have_many(:comments).dependent(:destroy)

    should belong_to(:assignee).class_name("User").optional
    should belong_to(:list)
  end

  context "validations" do
    should validate_presence_of(:title)

    should define_enum_for(:priority).with_values({ low: 0, medium: 1, high: 2 })

    should define_enum_for(:status).with_values({ todo: 0, in_progress: 1, completed: 2 })
  end

  test "default status is todo" do
    task = Task.new(title: "New Task")
    assert_equal "todo", task.status
  end

  test "should deadline can be nil" do
    @task.deadline = nil
    assert @task.valid?
  end

  test "should deadline can be in past" do
    @task.deadline = Date.yesterday
    assert_not @task.valid?
    assert_includes @task.errors[:deadline], "must be greater than #{Date.today}"
  end

  test "should deadline cannot be today" do
    @task.deadline = Date.today
    assert_not @task.valid?
    assert_includes @task.errors[:deadline], "must be greater than #{Date.today}"
  end

  test "should deadline can be in future" do
    @task.deadline = Date.tomorrow
    assert @task.valid?
  end
end
