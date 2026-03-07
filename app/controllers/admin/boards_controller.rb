class Admin::BoardsController < Admin::ApplicationController
  layout "admin"
  before_action :set_board, only: %i[show edit update destroy]

  def index
    @users = User.all
    @boards = Board.includes(:user)
                   .by_name(params[:search])
                   .by_user(params[:user_id])
                   .page(params[:page])
                   .per(20)
  end

  def show
  end

  def new
    @board = Board.new
    @users = User.pluck(:name, :id)
  end

  def create
    @board = Board.new(board_params)

    if @board.save
      redirect_to admin_board_path(@board), notice: "Board was successfully created."
    else
      @users = User.pluck(:name, :id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.pluck(:name, :id)
  end

  def update
    if @board.update(board_params)
      redirect_to admin_board_path(@board), notice: "Board was successfully updated."
    else
      @users = User.pluck(:name, :id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy!
    redirect_to admin_boards_path, notice: "Board was successfully destroyed."
  end

  private

  def board_params
    params.require(:board).permit(:name, :description, :color, :visibility, :archived_at, :user_id)
  end

  def set_board
    @board = Board.find(params[:id])
  end
end
