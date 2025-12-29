class Api::V1::FailureApp < Devise::FailureApp
  def respond
    if request_format == :json
      json_error_response
    else
      super
    end
  end

  private

  def request_format
    request.format
  end

  def json_error_response
    render json: {
      error: i18n_message,
      success: false
    }, status: :unauthorized
  end
end
