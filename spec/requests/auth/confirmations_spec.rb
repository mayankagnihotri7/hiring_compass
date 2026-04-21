# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth::Confirmations", type: :request do
  describe "GET auth/confirmation" do
    let(:user) { create(:user, :not_confirmed) }

    it "confirms user with valid token" do
      raw_token, enc = Devise.token_generator.generate(User, :confirmation_token)
      user.update!(confirmation_token: enc)

      send_request :get, "/auth/confirmation", params: { confirmation_token: raw_token }

      expect(response).to have_http_status(:ok)
      expect(user.reload.confirmed?).to eq(true)
    end

    it "fails with invalid token" do
      send_request :get, "/auth/confirmation", params: { confirmation_token: "123" }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
