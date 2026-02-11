class Api::V1::ListsController < Api::V1::ApplicationController
  include Paginatable
  include Moveable

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

  private

    def list_params
      params.require(:list).permit(:name)
    end

    def move_params
      params.require(:list).permit(:position)
    end
end
