# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
      before_action :authenticate_user!, only: %i[update destroy create]
      before_action :set_job, only: %i[update show destroy]

      def index
        jobs = params[:user_id].present? ? Job.where(user_id: params[:user_id]) : Job.all
        render json: jobs
      end

      def create
        job = Jobs::SaveService.new(current_user, job_params).call

        if job.persisted?
          render json: job, status: :ok
        else
          render json: { errors: job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: @job
      end

      def update
        Jobs::SaveService.new(current_user, job_params, @job).call

        if @job.errors.empty?
          render json: @job
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
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
            :title, :status, :currency, :min_salary, :max_salary, :description, :category,
            technologies: [:id, :name]
          )
        end
    end
  end
end
