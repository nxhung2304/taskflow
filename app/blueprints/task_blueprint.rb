class TaskBlueprint < ApplicationBlueprint
  view :default do
    fields :title, :description, :position, :priority, :deadline, :status, :list_id, :assignee_id, :comments_count
  end

  view :with_comments do
    include_view :default

    # TODO: Uncomment when CommentBlueprint is implemented
    # association :comments, blueprint: CommentBlueprint, view: :default
  end
end
