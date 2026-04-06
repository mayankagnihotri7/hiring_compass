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
        expect(json_response).to include(
          "id", "title", "description", "status", "user_id", "category", "location", "years_of_experience"
        )
      end
    end

    context "when invalid params are passed" do
      it "returns an error" do
        invalid_job_params = attributes_for(:job, title: nil, user_id: user.id)

        expect {
          send_request :post, api_v1_jobs_path(job: invalid_job_params), headers: auth_headers(user)
        }.not_to change(Job, :count)

        expect(response).to have_http_status(:unprocessable_content)
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

    context "when query params are passed" do
      it "filters results" do
        tech_name = job_one.technologies.first.name

        send_request :get, api_v1_jobs_path(technology: tech_name), headers: auth_headers(user)

        expect(json_response.count).to eq(1)
        expect(json_response[0]["technologies"].map { |tech| tech["name"] }).to include(tech_name)
      end

      it "filters by salary range" do
        job_four = create(:job, :with_technology, min_salary: 50000, max_salary: 80000, user: user_two)
        job_five = create(:job, :with_technology, min_salary: 90000, max_salary: 120000, user: user_two)

        send_request :get, api_v1_jobs_path(min_salary: 50000, max_salary: 100000), headers: auth_headers(user)

        expect(json_response.count).to eq(1)
        expect(json_response[0]["id"]).to eq(job_four.id)
      end

      it "filters by category" do
        marketing_job = create(:job, category: "marketing", user: user)

        send_request :get, api_v1_jobs_path(category: "tech"), headers: auth_headers(user)

        tech_jobs = json_response.map { |tech| tech["category"] }

        expect(tech_jobs).to all(eq("tech"))
        expect(tech_jobs).not_to include(marketing_job.category)
      end

      it "filters by status" do
        closed_job = create(:job, status: "closed", user: user)
        paused_job = create(:job, status: "paused", user: user)

        send_request :get, api_v1_jobs_path(status: "open"), headers: auth_headers(user)

        job_status = json_response.map { |st| st["status"] }

        expect(job_status).not_to include(closed_job.status, paused_job.status)
      end

      it "combines multiple filters" do
        tech_name = job_one.technologies.first.name

        send_request :get, api_v1_jobs_path(
          technology: tech_name,
          category: "tech",
          min_salary: 1000
        ), headers: auth_headers(user)

        expect(json_response.count).to be >= 1

        json_response.each do |job|
          expect(job["category"]).to eq("tech")
          expect(job["min_salary"]).to be >= 1000
        end
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

        expect(response).to have_http_status(:unprocessable_content)
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
