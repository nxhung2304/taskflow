require "rails_helper"

RSpec.describe Board, type: :model do
  subject { build(:board) }

  describe "associations" do
    it { is_expected.to have_many(:lists).dependent(:destroy) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    # name
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it "validates uniqueness of name scoped to user_id" do
      user = create(:user)
      create(:board, user: user, name: "Duplicate Name")
      board = build(:board, user: user, name: "Duplicate Name")
      expect(board).not_to be_valid
    end

    # description
    it { is_expected.to allow_value(nil).for(:description) }
    it { is_expected.to allow_value("").for(:description) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }

    # color
    it { is_expected.to validate_length_of(:color).is_at_most(9) }

    # visibility
    it { is_expected.to allow_value(true).for(:visibility) }
    it { is_expected.to allow_value(false).for(:visibility) }
    it { is_expected.not_to allow_value(nil).for(:visibility) }

    # archived_at
    it { is_expected.to allow_value(nil).for(:archived_at) }
    it { is_expected.to allow_value(Date.today + 1.day).for(:archived_at) }
    it { is_expected.not_to allow_value(Date.today - 1.day).for(:archived_at) }

    # lists_count
    it { is_expected.to validate_numericality_of(:lists_count).only_integer.is_greater_than_or_equal_to(0) }
  end
end
