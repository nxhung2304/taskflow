class Api::V1::BoardsController < Api::V1::ApplicationController
  before_action :set_board, only: %i[show update destroy]

  def index
    @boards = current_api_v1_user.boards.ordered.page(params[:page]).per(params[:per_page])

    render json: BoardBlueprint.render(@boards,
      root: :boards,
      meta: {
        current_page: @boards.current_page,
        total_pages: @boards.total_pages,
        total_count: @boards.total_count
      })
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
