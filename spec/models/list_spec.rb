require "rails_helper"

RSpec.describe List, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to belong_to(:board) }
  end

  describe "validations" do
    # name
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    # tasks_count
    it { is_expected.to validate_numericality_of(:tasks_count).only_integer.is_greater_than_or_equal_to(0) }
  end
end
