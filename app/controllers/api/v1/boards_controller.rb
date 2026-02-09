class Api::V1::BoardsController < Api::V1::ApplicationController
  include Paginatable

  before_action :set_board, only: %i[show update destroy]

  def index
    boards = current_api_v1_user.boards.ordered

    render_paginated_collection(boards, BoardBlueprint, root: :boards)
  end

  def show
    render json: BoardBlueprint.render(@board)
  end

  def create
    board = current_api_v1_user.boards.create!(board_params)

    render json: BoardBlueprint.render(board), status: :created
  end

  def update
    @board.update!(board_params)

    render json: BoardBlueprint.render(@board)
  end

  def destroy
    @board.destroy!

    head :no_content
  end

  private

  def board_params
    params.require(:board).permit(:name, :description, :archived_at, :color, :visibility)
  end

  def set_board
    @board = current_api_v1_user.boards.find(params[:id])
  end
end
