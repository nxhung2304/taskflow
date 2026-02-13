class Api::V1::FailureApp < Devise::FailureApp
  def respond
    if json_request?
      json_error_response
    else
      super
    end
  end

  private

  def json_request?
    request.content_type&.include?("json") || request.format.json?
  end

  def json_error_response
    self.status = :unauthorized
    self.content_type = "application/json"
    self.response_body = { error: i18n_message, success: false }.to_json
  end
end
