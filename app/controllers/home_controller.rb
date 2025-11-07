class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @welcome_message = "Welcome to Our Application!"
  end
end
