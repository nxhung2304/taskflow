# == Schema Information
#
# Table name: boards
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  color       :string(9)        default("#CCCCCC"), not null
#  description :text
#  name        :string           not null
#  position    :integer          default(0), not null
#  visibility  :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_boards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Board < ApplicationRecord
  # associations
  has_many :lists, dependent: :destroy
  belongs_to :user

  # validation
  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :archived_at, comparison: { greater_than_or_equal_to: -> { Date.today } }, if: :archived_at?
  validates :color, length: { maximum: 9 }, format: { with: /\A#(?:[0-9a-fA-F]{3}){1,2}(?:[0-9a-fA-F]{2})?\z/ }
  validates :visibility, inclusion: { in: [ true, false ] }
end
