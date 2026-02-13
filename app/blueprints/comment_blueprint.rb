class CommentBlueprint < ApplicationBlueprint
  fields :content

  view :with_author do
    association :user, blueprint: UserBlueprint, name: :author
  end
end
