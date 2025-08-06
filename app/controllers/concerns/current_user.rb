module CurrentUser
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    user_id = request.headers["X-User-ID"]

    if user_id.blank?
      render json: { error: "X-User-ID header is required" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: user_id)
    unless @current_user
      render json: { error: "User not found" }, status: :unauthorized and return
    end
  end
end
