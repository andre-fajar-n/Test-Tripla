class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from StandardError, with: :render_internal_server_error
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_internal_server_error(exception)
    Rails.logger.error(exception.full_message) # still log full message
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
