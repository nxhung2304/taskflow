class CommentBlueprint < ApplicationBlueprint
  fields :content, :task_id, :user_id

  view :with_author do
    association :user, blueprint: UserBlueprint, name: :author
  end
end
