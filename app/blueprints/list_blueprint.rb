class ListBlueprint < ApplicationBlueprint
  view :default do
    fields :name, :position, :board_id
  end

  view :with_tasks do
    include_view :default

    # TODO: Uncomment when TaskBlueprint is implemented
    # association :task, blueprint: TaskBlueprint, view: :default
  end
end
