# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :text
#  priority    :integer
#  due_date    :date
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @task = tasks(:one)
  end

  context "validations" do
    should validate_presence_of(:title)

    should define_enum_for(:priority).with_values({ low: 1, medium: 2, high: 3 })

    should define_enum_for(:status).with_values({ pending: 1, in_progress: 2, completed: 3 })
  end

  test "default status is pending" do
    task = Task.new(title: "New Task")
    assert_equal "pending", task.status
  end

  test "should due_date can be nil" do
    @task.due_date = nil
    assert @task.valid?
  end

  test "should due_date can be in past" do
    @task.due_date = Date.yesterday
    assert_not @task.valid?
    assert_includes @task.errors[:due_date], "must be greater than #{Date.today}"
  end

  test "should due_date cannot be today" do
    @task.due_date = Date.today
    assert_not @task.valid?
    assert_includes @task.errors[:due_date], "must be greater than #{Date.today}"
  end

  test "should due_date can be in future" do
    @task.due_date = Date.tomorrow
    assert @task.valid?
  end
end
