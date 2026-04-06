# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::JobApplicationsController", type: :request do
  let!(:user) { create(:user) }
  let!(:job) { create(:job, user: user) }
  let!(:resume) { fixture_file_upload(Rails.root.join("tmp", "storage", "resume.pdf")) }

  describe "#create" do
    context "when valid params are passed" do
      it "sends email on create" do
        job_app = attributes_for(:job_application)

        expect {
          send_request :post,
            api_v1_job_applications_path(job_id: job.id),
            headers: auth_headers(user),
            params: {
              job_application: job_app.merge(resume: resume)
            }
        }.to have_enqueued_mail(JobApplicationMailer, :application_received)
      end

      it "creates job application" do
        job_app = attributes_for(:job_application)

        expect {
          send_request :post,
            api_v1_job_applications_path(job_id: job.id),
            headers: auth_headers(user),
            params: {
              job_application: job_app.merge(resume: resume)
            }
        }.to change(JobApplication, :count).by(1)
      end
    end

    context "when resume not attached" do
      it "does not create" do
        job_app = attributes_for(:job_application)

        expect {
          send_request :post,
            api_v1_job_applications_path(job_id: job.id),
            headers: auth_headers(user),
            params: {
              job_application: job_app
            }.to_json
        }.to_not change(JobApplication, :count)

        expect(json_response["errors"]).to include("Resume can't be blank")
      end
    end

    context "when invalid params" do
      it "does not create" do
        job_app = attributes_for(:job_application)

        expect {
          send_request :post,
            api_v1_job_applications_path(job_id: job.id),
            headers: auth_headers(user),
            params: {
              job_application: job_app.merge(resume: resume, last_name: nil)
            }.to_json
        }.to_not change(JobApplication, :count)

        expect(json_response["errors"]).to include("Last name can't be blank")
      end
    end
  end

  describe "#update" do
    let(:user_two) { create(:user, :admin) }
    let(:job_application) { create(:job_application) }

    context "when valid params" do
      it "sends correct email" do
        expect {
          send_request :put,
            api_v1_job_application_path(job_id: job_application.job_id, id: job_application.id),
            headers: auth_headers(user_two),
            params: { job_application: { status: "hired" } }.to_json
        }.to have_enqueued_mail(JobApplicationMailer, :application_hired)

        expect(json_response["status"]).to eq("hired")
      end
    end

    context "when invalid params" do
      it "does not update" do
        expect {
          send_request :put,
            api_v1_job_application_path(job_id: job_application.job_id, id: job_application.id),
            headers: auth_headers(user_two),
            params: { job_application: { status: nil } }.to_json
        }.to_not change { job_application.status }

        expect(json_response["errors"]).to include("Status can't be blank")
      end
    end
  end

  describe "#show" do
    let(:user_two) { create(:user, :admin) }
    let!(:job_application) { create(:job_application) }

    context "when valid id is given" do
      it "fetches job application" do
        send_request :get, api_v1_job_application_path(job_id: job_application.job_id, id: job_application.id),
          headers: auth_headers(user_two)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when invalid id is given" do
      it "gives error" do
        send_request :get, api_v1_job_application_path(job_id: job_application.job_id, id: "1234"),
          headers: auth_headers(user_two)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  private

    def fixture_file_upload(filename)
      Rack::Test::UploadedFile.new(filename, "application/pdf")
    end
end
