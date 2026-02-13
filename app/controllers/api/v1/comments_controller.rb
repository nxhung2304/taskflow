class Api::V1::CommentsController < Api::V1::ApplicationController
  load_and_authorize_resource :task, only: %i[index create]
  load_and_authorize_resource :comment, only: %i[show update destroy]

  include Paginatable

  def index
    comments = @task.comments.ordered

    render_paginated_collection(comments, CommentBlueprint, root: :comments)
  end

  def show
    render json: CommentBlueprint.render(@comment, view: :with_author)
  end

  def create
    task = @task.comments.create!(comment_params.merge(user: current_api_v1_user))

    render json: CommentBlueprint.render(task), status: :created
  end

  def update
    @comment.update!(comment_params)

    render json: CommentBlueprint.render(@comment)
  end

  def destroy
    @comment.destroy!

    head :no_content
  end

  private

    def comment_params
      params.require(:comment).permit(
        :content
      )
    end
end
