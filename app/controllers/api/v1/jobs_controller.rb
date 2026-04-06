# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
      before_action :authenticate_user!, only: %i[update destroy create]
      before_action :set_job, only: %i[update show destroy]

      def index
        # rubocop:disable Layout/IndentationWidth
        # rubocop:disable Layout/EndAlignment
        jobs = if params[:user_id].present?
                 Job.includes(:technologies).where(user_id: params[:user_id])
               else
                 filter_jobs
               end
        render json: jobs.as_json(include: :technologies)
      end

      def create
        job = Jobs::SaveService.new(current_user, job_params).call

        if job.persisted?
          render json: job, status: :ok
        else
          render json: { errors: job.errors.full_messages }, status: :unprocessable_content
        end
      end

      def show
        render json: @job.as_json(include: :technologies)
      end

      def update
        Jobs::SaveService.new(current_user, job_params, @job).call

        if @job.errors.empty?
          render json: @job
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @job.destroy

        head :no_content
      end

      def categories
        render json: { categories: Job.categories.keys }
      end

      private

        def set_job
          @job = Job.find(params[:id])
        end

        def job_params
          params.require(:job).permit(
            :title, :status, :currency, :min_salary, :max_salary, :description, :category, :location,
            :years_of_experience, :company_name,
            technologies: [:id, :name]
          )
        end

        def filter_jobs
          jobs = Job.includes(:technologies).all
          jobs = jobs.search_by_text(params[:q]) if params[:q].present?
          jobs = jobs.by_category(params[:category]) if params[:category].present?
          jobs = jobs.includes(:technologies).by_technology(params[:technology]) if params[:technology].present?
          jobs = jobs.by_experience(params[:years_of_experience]) if params[:years_of_experience].present?
          jobs = jobs.by_location(params[:location]) if params[:location].present?
          jobs = jobs.by_status(params[:status]) if params[:status].present?
          jobs = jobs.by_min_salary(params[:min_salary]) if params[:min_salary].present?
          jobs = jobs.by_max_salary(params[:max_salary]) if params[:max_salary].present?
          jobs
        end
    end
  end
end
