module Api
  module V1
    module Auth
      class RegistrationsController < DeviseTokenAuth::RegistrationsController
        skip_before_action :verify_authenticity_token
        skip_before_action :authenticate_admin_user!

        private

          def sign_up_params
            params.permit(:name, :email, :password, :password_confirmation)
          end

          def render_create_error
            render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
          end
      end
    end
  end
end
