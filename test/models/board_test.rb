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
require "test_helper"

class BoardTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:lists).dependent(:destroy)
    should belong_to(:user)
  end

  context "validations" do
    # name
    should validate_presence_of(:name)
    should validate_length_of(:name).is_at_most(255)
    should validate_uniqueness_of(:name).scoped_to(:user_id)

    # description
    should allow_value(nil).for(:description)
    should allow_value("").for(:description)
    should validate_length_of(:description).is_at_most(1000)

    # position
    should validate_presence_of(:position)
    should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0)

    # color
    should validate_length_of(:color).is_at_most(9)

    # visibility
    should allow_value(true).for(:visibility)
    should allow_value(false).for(:visibility)
    should_not allow_value(nil).for(:visibility)

    # archived_at
    should allow_value(nil).for(:archived_at)
    should allow_value(Date.today + 1.day).for(:archived_at)
    should_not allow_value(Date.today - 1.day).for(:archived_at)
  end
end
