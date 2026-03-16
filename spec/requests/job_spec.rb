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
        expect(json_response).to include("id", "title", "description", "status", "user_id", "category")
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

  describe "#index" do
    let!(:user_two) { create(:user) }
    let!(:job_one) { create(:job, :with_technology, user:) }
    let!(:job_two) { create(:job, :with_technology, user:) }
    let!(:job_three) { create(:job, :with_technology, user: user_two) }

    context "when user id is passed" do
      it "fetches user jobs" do
        send_request :get, api_v1_jobs_path(user_id: user.id), headers: auth_headers(user)

        expect(json_response.count).to eq(2)
        expect(job_three.user_id).not_to eq(user.id)
      end
    end

    context "when user id is not passed" do
      it "fetches all jobs" do
        send_request :get, api_v1_jobs_path, headers: auth_headers(user)

        expect(json_response.count).to eq(3)
      end
    end
  end

  describe "#update" do
    let!(:job) { create(:job, user:) }

    context "when valid params are passed" do
      it "updates job" do
        send_request(
          :put, api_v1_job_path(id: job.id), headers: auth_headers(user),
          params: { job: { title: "Senior Rails Dev" } }.to_json)

        expect(response).to have_http_status(:ok)
        expect(json_response["title"]).to eq("Senior Rails Dev")
      end
    end

    context "when invalid params are passed" do
      it "cannot update job" do
        send_request(
          :put, api_v1_job_path(id: job.id), headers: auth_headers(user),
          params: { job: { title: nil } }.to_json)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#show" do
    let!(:job) { create(:job) }

    context "when valid id is given" do
      it "fetches job" do
        send_request :get, api_v1_job_path(id: job.id), headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when invalid id is given" do
      it "gives error" do
        send_request :get, api_v1_job_path(id: "123"), headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#destroy" do
    let!(:job) { create(:job, user:) }

    context "when valid id given" do
      it "removes job" do
        expect {
          send_request :delete, api_v1_job_path(id: job.id), headers: auth_headers(user)
        }.to change(Job, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect { job.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "invalid id" do
      it "raises not found" do
        send_request :delete, api_v1_job_path(id: "123"), headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "user not signed in" do
      it "cannot destroy" do
        send_request :delete, api_v1_job_path(id: job.id)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
