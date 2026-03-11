class Admin::HomeController < Admin::ApplicationController
  def index
    @boards_count = Board.count
    @users_count = User.count
    @lists_count = List.count
    @tasks_count = Task.count
  end
end
