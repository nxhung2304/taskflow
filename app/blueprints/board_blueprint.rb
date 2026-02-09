class BoardBlueprint < ApplicationBlueprint
  view :default do
    fields :name, :description, :archived_at, :color, :visibility, :position
  end

  view :with_user do
    include_view :default

    # TODO: Uncomment when UserBlueprint is implemented
    # association :user, blueprint: UserBlueprint, view: :default
  end

  view :with_lists do
    include_view :default

    # TODO: Uncomment when ListBlueprint is implemented
    # association :lists, blueprint: ListBlueprint, view: :default
  end
end
