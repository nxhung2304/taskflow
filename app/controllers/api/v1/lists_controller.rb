class Api::V1::ListsController < Api::V1::ApplicationController
  include Paginatable

  load_and_authorize_resource :board, only: %i[index create]
  load_and_authorize_resource :list, only: %i[show update destroy move]

  def index
    lists = @board.lists.ordered

    render_paginated_collection(lists, ListBlueprint, root: :lists)
  end

  def show
    render json: ListBlueprint.render(@list)
  end

  def create
    list = @board.lists.create!(list_params)

    render json: ListBlueprint.render(list), status: :created
  end

  def update
    @list.update!(list_params)

    render json: ListBlueprint.render(@list)
  end

  def destroy
    @list.destroy!

    head :no_content
  end

  def move
    position_form = PositionForm.new(position: move_params[:position])
    if position_form.valid?
      @list.insert_at(position_form.position.to_i)
      @list.reload

      render json: ListBlueprint.render(@list)
    else
      render json: { errors: position_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end

  def move_params
    params.require(:list).permit(:position)
  end
end
