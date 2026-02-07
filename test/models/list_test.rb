# == Schema Information
#
# Table name: lists
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  position    :integer          default(0), not null
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
require "test_helper"

class ListTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:tasks).dependent(:destroy)
    should belong_to(:board)
  end

  context "validations" do
    # name
    should validate_presence_of(:name)
    should validate_length_of(:name).is_at_most(255)

    # tasks_count
    should validate_numericality_of(:tasks_count).only_integer.is_greater_than_or_equal_to(0)
  end
end
