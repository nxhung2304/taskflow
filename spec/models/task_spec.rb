require "rails_helper"

RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe "associations" do
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to belong_to(:assignee).class_name("User").optional }
    it { is_expected.to belong_to(:list) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to define_enum_for(:priority).with_values({ low: 0, medium: 1, high: 2 }) }
    it { is_expected.to define_enum_for(:status).with_values({ todo: 0, in_progress: 1, completed: 2 }) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000).allow_blank }
    it { is_expected.to validate_numericality_of(:comments_count).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "default values" do
    it "sets default status to todo" do
      task = Task.new(title: "New Task")
      expect(task.status).to eq("todo")
    end
  end

  describe "deadline validation" do
    it "allows nil deadline" do
      subject.deadline = nil
      expect(subject).to be_valid
    end

    it "does not allow past deadline" do
      subject.deadline = Date.yesterday
      expect(subject).not_to be_valid
      expect(subject.errors[:deadline]).to include("must be greater than #{Date.today}")
    end

    it "does not allow today as deadline" do
      subject.deadline = Date.today
      expect(subject).not_to be_valid
      expect(subject.errors[:deadline]).to include("must be greater than #{Date.today}")
    end

    it "allows future deadline" do
      subject.deadline = Date.tomorrow
      expect(subject).to be_valid
    end
  end
end
