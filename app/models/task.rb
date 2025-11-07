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

class Task < ApplicationRecord
  enum :status, { pending: 1, in_progress: 2, completed: 3 }
  enum :priority, { low: 1, medium: 2, high: 3 }

  validates :title, presence: true
  validates :due_date, comparison: { greater_than: -> { Time.zone.today } }, if: -> { due_date.present? }

  after_initialize :set_default_status, if: :new_record?

  scope :by_status, ->(status) { where(status: statuses[status]) }
  scope :by_priority, ->(priority) { where(priority: priorities[priority]) }
  scope :by_due_date, ->(date) { where(due_date: date) }

  private

  def set_default_status
    self.status ||= :pending
  end
end
