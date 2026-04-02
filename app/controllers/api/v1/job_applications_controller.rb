# frozen_string_literal: true

module Api
  module V1
    class JobApplicationsController < ApplicationController
      before_action :authenticate_user!, only: %i[index update]
      before_action :set_job, only: %i[index create show update]
      before_action :set_job_application, only: %i[show update]

      def index
        render json: @job.as_json(include: :job_applications)
      end

      def create
        job_application = @job.job_applications.new(job_application_params)

        if job_application.save
          JobApplicationMailer.application_received(job_application).deliver_later

          render json: job_application
        else
          render json: { errors: job_application.errors.full_messages }, status: :unprocessable_content
        end
      end

      def show
        render json: @job_application
      end

      def update
        if current_user.role == "admin" || current_user.role == "recruiter"
          if @job_application.update(update_params)
            send_response_mail(@job_application)

            render json: @job_application
          else
            render json: { errors: @job_application.errors.full_messages }, status: :unprocessable_content
          end
        end
      end

      private

        def job_application_params
          params.require(:job_application).permit(
            :first_name, :last_name, :years_of_experience, :email, :status,
            :phone_number, :visa_sponsorship_required, :resume
          )
        end

        def update_params
          params.require(:job_application).permit(:status)
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
