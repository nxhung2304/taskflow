# == Schema Information
#
# Table name: tasks
#
#  id             :bigint           not null, primary key
#  comments_count :integer          default(0), not null
#  deadline       :datetime
#  description    :text
#  position       :integer
#  priority       :integer
#  status         :integer          default("todo"), not null
#  title          :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  assignee_id    :bigint
#  list_id        :bigint           not null
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
  include Orderable

  acts_as_list scope: :list

  # associations
  has_many :comments, dependent: :destroy
  belongs_to :list, counter_cache: true
  belongs_to :assignee, class_name: "User", optional: true

  # scopes
  scope :with_status, ->(status) { where(status: status) }
  scope :with_priority, ->(priority) { where(priority: priority) }
  scope :with_assignee_id, ->(assignee_id) { where(assignee_id: assignee_id) }

  # enums
  enum :status, { todo: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  # validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :deadline, comparison: { greater_than: -> { Time.zone.today } }, if: -> { deadline.present? }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :comments_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # custom validation
  validate :assignee_must_exist, if: -> { assignee_id.present? }

  # hooks
  after_initialize :set_default_status, if: :new_record?

  private

    def set_default_status
      self.status ||= :todo
    end

    def assignee_must_exist
      return if User.exists?(assignee_id)

      errors.add(:assignee_id, "must refer to an existing user")
    end
end
