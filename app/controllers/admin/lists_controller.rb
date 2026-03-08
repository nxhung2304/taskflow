class Admin::ListsController < Admin::ApplicationController
  layout "admin"

  LISTS_PER_PAGE = 20

  before_action :set_board, only: %i[index show new create edit update destroy]
  before_action :set_list, only: %i[show edit update destroy]
  before_action :set_boards_for_form, only: %i[new create]

  def index
    @lists = board_specific? ? fetch_board_lists : fetch_all_lists
    @board = @board_for_index
    @boards = Board.all unless board_specific?
  end

  def show; end

  def new
    @list = board_specific? ? @board.lists.build : List.new
  end

  def create
    @list = List.new(list_params)
    set_board_for_create

    if @list.save
      redirect_to redirect_path_after_action, notice: t("admin.lists.messages.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @list.update(list_params)
      redirect_to redirect_path_after_action, notice: t("admin.lists.messages.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy!
    redirect_to redirect_path_after_action, notice: t("admin.lists.messages.destroyed")
  end

  private

  def list_params
    params.require(:list).permit(:name, :board_id)
  end

  def set_board
    @board = Board.find(params[:board_id]) if params[:board_id].present?
  end

  def set_list
    @list = List.find(params[:id])
    @board = @list.board
  end

  def set_boards_for_form
    @boards = Board.all
  end

  def board_specific?
    params[:board_id].present?
  end

  def fetch_board_lists
    @board_for_index = @board
    @board.lists
          .by_name(params[:search])
          .page(params[:page])
          .per(LISTS_PER_PAGE)
  end

  def fetch_all_lists
    @board_for_index = nil
    List.includes(:board)
        .by_name(params[:search])
        .by_board(params[:filter_board_id])
        .page(params[:page])
        .per(LISTS_PER_PAGE)
  end

  def set_board_for_create
    @list.board_id = @board.id if @board
  end

  def redirect_path_after_action
    board_specific? ? admin_board_lists_path(@board) : admin_lists_path
  end
end
