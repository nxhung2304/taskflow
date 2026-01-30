module Api
  module V1
    module Auth
      class SessionsController < DeviseTokenAuth::SessionsController
        skip_before_action :verify_authenticity_token

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
