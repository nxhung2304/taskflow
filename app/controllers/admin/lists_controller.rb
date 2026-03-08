class Admin::ListsController < Admin::ApplicationController
  layout "admin"
  before_action :set_board, only: %i[show new create edit update destroy]
  before_action :set_list, only: %i[show edit update destroy]
  before_action :set_boards, only: %i[new create]

  def index
    if params[:board_id]
      # Board-specific lists
      set_board
      @lists = @board.lists
                      .by_name(params[:search])
                      .page(params[:page])
                      .per(20)
    else
      # All lists across all boards
      @lists = List.includes(:board)
                   .by_name(params[:search])
                   .by_board(params[:filter_board_id])
                   .page(params[:page])
                   .per(20)
      @board = nil
      @boards = Board.all
    end
  end

  def show; end

  def new
    if params[:board_id]
      # Board-specific new form
      set_board
      @list = @board.lists.build
    else
      # Global new form with board selection
      @list = List.new
      @list.board_id = params[:board_id]
    end
  end

  def create
    @list = List.new(list_params)

    # If board_id is in the URL, use it (board-specific create)
    @list.board_id = @board.id if @board

    if @list.save
      redirect_path = @board ? admin_board_lists_path(@board) : admin_lists_path
      redirect_to redirect_path, notice: t("admin.lists.messages.created")
    else
      @boards = Board.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @list.update(list_params)
      redirect_to admin_board_lists_path(@board), notice: t("admin.lists.messages.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy!
    redirect_to admin_board_lists_path(@board), notice: t("admin.lists.messages.destroyed")
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

  def set_boards
    @boards = Board.all
  end
end
