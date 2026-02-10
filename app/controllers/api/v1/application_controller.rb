module Api
  module V1
    class ApplicationController < ActionController::API
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_api_v1_user!

      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from CanCan::AccessDenied, with: :render_access_denied

      private

        def render_unprocessable_entity(exception)
          render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
        end

        def render_not_found(_exception)
          render json: { errors: [ "Resource not found" ] }, status: :not_found
        end

        def render_access_denied(exception)
          render json: { errors: [ exception.message ] }, status: :forbidden
        end

        # FIX: error undefined local variable or method 'current_user'. Because
        # - Cancancan expects a method named 'current_user' to get the current logged in user
        # - But DeviseTokenAuth creates a method named 'current_api_v1_user' based on the namespace of the controller
        # - So we need to map 'current_user' to 'current_api_v1_user'
        def current_ability
          @current_ability ||= ::Ability.new(current_api_v1_user)
        end
    end
  end
end
