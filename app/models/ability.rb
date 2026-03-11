# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Admin users have full access to all resources
    if admin_user?(user)
      can :manage, :all
      return
    end

    # Regular users have scoped access based on board ownership
    return unless user.present?

    can :manage, Board, user_id: user.id
    can :manage, List, board: { user_id: user.id }
    can :manage, Task, list: { board: { user_id: user.id } }
    can :manage, Comment, task: { list: { board: { user_id: user.id } } }
  end

  private

  def admin_user?(user)
    user.is_a?(AdminUser)
  end
end
