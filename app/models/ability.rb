# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    can :manage, Board, user_id: user.id
    can :manage, List, board: { user_id: user.id }
  end
end
