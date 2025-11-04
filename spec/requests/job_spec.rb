# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Jobs", type: :request do

  let(:user) { create(:user) }

  describe "#create" do
    context "when valid params are passed" do
      it "creates job successfully" do
        job = attributes_for(:job, user_id: user.id)

        expect {
          send_request :post, api_v1_jobs_path(job:), headers: auth_headers(user)
        }.to change(Job, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response).to include("id", "title", "description", "status", "user_id")
      end
    end

    context "when invalid params are passed" do
      it "returns an error" do
        invalid_job_params = attributes_for(:job, title: nil, user_id: user.id)

        expect {
          send_request :post, api_v1_jobs_path(job: invalid_job_params), headers: auth_headers(user)
        }.not_to change(Job, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to include("Title can't be blank")
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        job = attributes_for(:job)

        expect {
          send_request :post, api_v1_jobs_path(job:)
        }.not_to change(Job, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when payload is empty" do
      it "returns bad request" do
        send_request :post, api_v1_jobs_path(job: {}), headers: auth_headers(user)

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
