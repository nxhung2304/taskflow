class TaskBlueprint < ApplicationBlueprint
  view :default do
    fields :title, :description, :position, :priority, :deadline, :status, :list_id, :assignee_id, :comments_count
  end

  view :with_comments do
    include_view :default

    association :comments, blueprint: CommentBlueprint
  end
end
