# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization

  before_action :configure_devise_params, if: :devise_controller?

  private

    def configure_devise_params
      devise_parameter_sanitizer.permit(
        :sign_up, keys: [:first_name, :last_name, :email, :phone_number, :bio, :address, :role]
      )
    end
end
