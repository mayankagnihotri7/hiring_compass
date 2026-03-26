# frozen_string_literal: true

module Api
  module V1
    class JobApplicationsController < ApplicationController
      before_action :authenticate_user!, only: %i[index update]
      before_action :set_job, only: %i[index create show]
      before_action :set_job_application, only: %i[show]

      def index
        render json: @job.as_json(include: :job_applications)
      end

      def create
        job_application = @job.job_applications.create(job_application_params)

        if job_application.persisted?
          render json: job_application
        else
          render json: { errors: job_application.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: @job_application
      end

      def update
        if current_user.role == "admin" || current_user == "recruiter"
          if @job_application.update(status: params[:status])
            render json: @job_application
          else
            render json: { errors: @job_application.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private

        def job_application_params
          params.require(:job_application).permit(
            :first_name, :last_name, :years_of_experience, :email,
            :phone_number, :visa_sponsorship_required, :status
          )
        end

        def set_job
          @job = Job.find(params[:job_id])
        end

        def set_job_application
          @job_application = @job.job_applications.where(id: params[:id]).first
        end
    end
  end
end
