# == Schema Information
#
# Table name: lists
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  position    :integer
#  tasks_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  board_id    :bigint           not null
#
# Indexes
#
#  index_lists_on_board_id  (board_id)
#
# Foreign Keys
#
#  fk_rails_...  (board_id => boards.id)
#
class List < ApplicationRecord
  include Orderable

  acts_as_list scope: :board

  # associations
  has_many :tasks, dependent: :destroy
  belongs_to :board, counter_cache: true

  # validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :tasks_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
