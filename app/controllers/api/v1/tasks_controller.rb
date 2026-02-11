class Api::V1::TasksController < Api::V1::ApplicationController
  include Paginatable
  include Moveable
  include Filterable

  load_and_authorize_resource :list, only: %i[index create]
  load_and_authorize_resource :task, only: %i[show update destroy move]

  def index
    tasks = collection_filter_by(@list.tasks.ordered, params.slice(:status, :priority, :assignee_id))

    render_paginated_collection(tasks, TaskBlueprint, root: :tasks)
  end

  def show
    render json: TaskBlueprint.render(@task)
  end

  def create
    task = @list.tasks.create!(task_params)

    render json: TaskBlueprint.render(task), status: :created
  end

  def update
    @task.update!(task_params)

    render json: TaskBlueprint.render(@task)
  end

  def destroy
    @task.destroy!

    head :no_content
  end

  private

    def task_params
      params.require(:task).permit(
        :title,
        :description,
        :priority,
        :deadline,
        :status,
        :position,
        :assignee_id
      )
    end

    def move_params
      params.require(:task).permit(:position)
    end
end
