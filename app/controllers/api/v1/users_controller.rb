module Api
  module V1
    class UsersController < ApplicationController
      def me
        render json: UserBlueprint.render(current_api_v1_user)
      end
    end
  end
end
