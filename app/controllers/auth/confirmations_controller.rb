# frozen_string_literal: true

class Auth::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  def show
    user = resource_class.confirm_by_token(params[:confirmation_token])

    if user.errors.empty?
      render json: {
        success: true,
        message: "Email has been confirmed"
      }, status: :ok
    else
      render json: {
        success: false,
        message: user.errors.full_messages
      }, status: :unprocessable_content
    end
  end
end
