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

class Task < ApplicationRecord
  # associations
  has_many :comments, dependent: :destroy
  belongs_to :list
  belongs_to :assignee, class_name: "User", optional: true

  # enums
  enum :status, { todo: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  # validations
  validates :title, presence: true
  validates :deadline, comparison: { greater_than: -> { Time.zone.today } }, if: -> { deadline.present? }

  # hooks
  after_initialize :set_default_status, if: :new_record?

  # scopes
  scope :by_status, ->(status) { where(status: statuses[status]) }
  scope :by_priority, ->(priority) { where(priority: priorities[priority]) }

  private

  def set_default_status
    self.status ||= :todo
  end
end
