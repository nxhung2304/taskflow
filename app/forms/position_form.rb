class PositionForm
  include ActiveModel::Model

  attr_accessor :position

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
