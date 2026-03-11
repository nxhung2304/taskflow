class Admin::TasksController < Admin::ApplicationController
  TASKS_PER_PAGE = 20

  load_and_authorize_resource :task
  before_action :set_list, only: %i[index show new create edit update destroy]
  before_action :set_list_from_task, only: %i[show edit update destroy]
  before_action :set_users_for_form, only: %i[index new create edit update]

  def index
    @tasks = list_specific? ? fetch_list_tasks : fetch_all_tasks
    @list = @list_for_index
    @lists = List.all unless list_specific?
  end

  def show; end

  def new
    @task = list_specific? ? @list.tasks.build : Task.new
  end

  def create
    @task = Task.new(task_params)
    set_list_for_create

    if @task.save
      redirect_to redirect_path_after_action, notice: t("admin.tasks.messages.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to redirect_path_after_action, notice: t("admin.tasks.messages.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy!
    redirect_to redirect_path_after_action, notice: t("admin.tasks.messages.destroyed")
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :deadline, :list_id, :assignee_id)
  end

  def set_list
    @list = List.find(params[:list_id]) if params[:list_id].present?
  end

  def set_list_from_task
    @list = @task.list if @task
  end

  def set_users_for_form
    @users = User.pluck(:name, :id)
  end

  def set_lists_for_form
    @lists = List.all
  end

  def list_specific?
    params[:list_id].present?
  end

  def fetch_list_tasks
    @list_for_index = @list
    @list.tasks
         .by_title(params[:search])
         .with_status(params[:status])
         .with_priority(params[:priority])
         .with_assignee_id(params[:assignee_id])
         .includes(:assignee, :list)
         .page(params[:page])
         .per(TASKS_PER_PAGE)
  end

  def fetch_all_tasks
    @list_for_index = nil
    Task.includes(:assignee, :list)
        .by_title(params[:search])
        .with_status(params[:status])
        .with_priority(params[:priority])
        .with_assignee_id(params[:assignee_id])
        .by_list(params[:filter_list_id])
        .page(params[:page])
        .per(TASKS_PER_PAGE)
  end

  def set_list_for_create
    @task.list_id = @list.id if @list
  end

  def redirect_path_after_action
    list_specific? ? admin_list_tasks_path(@list) : admin_tasks_path
  end
end
