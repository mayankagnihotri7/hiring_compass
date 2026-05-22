# frozen_string_literal: true

module Api
  module V1
    class JobApplicationsController < ApplicationController
      include RateLimitable

      before_action :authenticate_user!, only: %i[index update download bulk_update_status]
      before_action :set_job, only: %i[index create show update download bulk_update_status]
      before_action :set_job_application, only: %i[show update download]

      rate_limit_create to: 15, within: 1.minute
      rate_limit_update to: 15, within: 1.minute
      rate_limit_download to: 15, within: 1.minute

      def index
        render json: @job.as_json(include: :job_applications)
      end

      def create
        job_application = @job.job_applications.new(job_application_params)
        authorize job_application

        if job_application.save
          JobApplicationMailer.application_received(job_application).deliver_later

          render json: job_application
        else
          render json: { errors: job_application.errors.full_messages }, status: :unprocessable_content
        end
      end

      def show
        authorize @job_application

        render json: @job_application
      end

      def update
        authorize @job_application

        if @job_application.update(update_params)
          send_response_mail(@job_application)

          render json: @job_application
        else
          render json: { errors: @job_application.errors.full_messages }, status: :unprocessable_content
        end
      end

      def download
        # rubocop:disable Layout/ArgumentAlignment
        if @job_application.resume.attached?
          send_data @job_application.resume.download,
                    filename: @job_application.resume.filename.to_s,
                    type: @job_application.resume.content_type,
                    disposition: "attachment"
        else
          render json: { error: "File not attached" }, status: :not_found
        end
      end

      def send_otp
        email = job_application_params[:email]
        first_name = job_application_params[:first_name]

        if email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
          code = JobApplication.generate_otp(email)

          JobApplicationMailer.verification_code(first_name, email, code).deliver_later

          render json: { message: "Verification code sent." }, status: :ok
        else
          render json: { error: "Valid email is required." }, status: :unprocessable_content
        end

      rescue OtpVerifiable::OtpCooldownError
        render json: { errors: "Please wait before requesting another code." }, status: :too_many_requests
      rescue OtpVerifiable::OtpRateLimitError
        render json: { errors: "Too many attempts. Please try again later." }, status: :too_many_requests
      end

      def bulk_update_status
        status = ids_params[:status]

        unless JobApplication.statuses.key?(status)
          return render json: { errors: "invalid status" }, status: :unprocessable_content
        end

        ids = ids_params[:ids]
        job_applications = policy_scope(JobApplication)

        ActiveRecord::Base.transaction do
          found = job_applications.where(id: ids)
          found.update_all(status: status)

          BulkStatusUpdateJob.perform_async(found.pluck(:id))

          render json: { message: "Job Applications updated." }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_content
      rescue => e
        render json: { errors: "Something went wrong." }, status: :internal_server_error
      end

      private

        def job_application_params
          params.require(:job_application).permit(
            :first_name, :last_name, :years_of_experience, :email, :status,
            :phone_number, :visa_sponsorship_required, :resume, :otp_code
          )
        end

        def update_params
          params.require(:job_application).permit(:status)
        end

        def ids_params
          params.require(:job_application).permit(:status, ids: [])
        end

        def set_job
          @job = Job.find(params[:job_id])
        end

        def set_job_application
          @job_application = @job.job_applications.find(params[:id])
        end

        def send_response_mail(job_application)
          case job_application.status
          when "shortlisted"
            JobApplicationMailer.application_shortlisted(job_application).deliver_later
          when "hired"
            JobApplicationMailer.application_hired(job_application).deliver_later
          when "rejected"
            JobApplicationMailer.application_rejected(job_application).deliver_later
          end
        end
    end
  end
end
