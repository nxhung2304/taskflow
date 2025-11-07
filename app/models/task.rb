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
  validates :priority, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :status, inclusion: { in: Task.statuses.keys }, allow_nil: true
  validates :due_date, comparison: { greater_than: Date.today }, if: -> { due_date.present? }

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :pending
  end
end
