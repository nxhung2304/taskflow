module Api
  module V1
    module Auth
      class SessionsController < DeviseTokenAuth::SessionsController
        protect_from_forgery

        protected

        def render_create_success
          render json: {
            user: current_user.as_json(only: [ :id, :email, :name ]),
            success: true
          }, status: :ok
        end

        def render_create_error
          render json: {
            errors: resource_errors,
            success: false
          }, status: :unauthorized
        end
      end
    end
  end
end
