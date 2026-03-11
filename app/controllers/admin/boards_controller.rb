class Admin::BoardsController < Admin::ApplicationController
  load_and_authorize_resource :board
  before_action :set_users, only: %i[new create edit update]

  def index
    @users = User.all
    @boards = Board.includes(:user)
                   .by_name(params[:search])
                   .by_user(params[:user_id])
                   .page(params[:page])
                   .per(20)
  end

  def show; end

  def new
    @board = Board.new
  end

  def create
    @board = Board.new(board_params)

    if @board.save
      redirect_to admin_boards_path, notice: t("admin.boards.messages.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @board.update(board_params)
      redirect_to admin_boards_path, notice: t("admin.boards.messages.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy!
    redirect_to admin_boards_path, notice: t("admin.boards.messages.destroyed")
  end

  private

  def board_params
    params.require(:board).permit(:name, :description, :color, :visibility, :archived_at, :user_id)
  end

  def set_users
    @users = User.pluck(:name, :id)
  end
end
