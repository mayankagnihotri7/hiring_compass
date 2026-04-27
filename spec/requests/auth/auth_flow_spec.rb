# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth Flow", type: :request do
  describe "sign up -> confirmation -> sign in" do
    it "flows correctly" do
      user_attrs = attributes_for(:user)

      # Sign up
      send_request :post, "/auth", params: user_attrs
      expect(response).to have_http_status(:ok)

      user = User.find_by(email: user_attrs[:email])
      expect(user).to be_present
      expect(user.confirmed?).to be false

      # Cannot sign in before confirmation
      send_request :post, "/auth/sign_in", params: { email: user.email, password: user_attrs[:password] }
      expect(response).to have_http_status(:unauthorized)

      # Confirm via token
      raw_token = user.confirmation_token
      send_request :get, "/auth/confirmation", params: {
        confirmation_token: raw_token
      }

      expect(response).to have_http_status(:ok)

      user.reload
      expect(user.confirmed?).to be true

      # Sign in
      send_request :post, "/auth/sign_in", params: { email: user.email, password: user_attrs[:password] }
      expect(response).to have_http_status(:ok)
    end
  end
end
