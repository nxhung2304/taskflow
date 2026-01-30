module Api
  module V1
    class UsersController < ApplicationController
      def me
        render "api/v1/users/me"
      end
    end
  end
end
