# frozen_string_literal: true

module Jobs
  class SaveService
    attr_accessor :user, :params, :job

    def initialize(user, params, job = nil)
      @user = user
      @params = params
      @job = job
    end

    def call
      ActiveRecord::Base.transaction do
        @job ||= user.jobs.new
        @job.assign_attributes(job_attrs)
        @job.technologies = resolve_technologies if params[:technologies].present?
        @job.save!
        @job
      end
    rescue ActiveRecord::RecordInvalid => e
      handle_error(e)
    rescue ActiveRecord::RecordNotFound => e
      handle_error(e)
    end

    private

      def job_attrs
        params.except(:technologies)
      end

      def resolve_technologies
        params[:technologies].map do |tech|
          if tech[:id].present?
            Technology.find(tech[:id])
          else
            Technology.find_or_create_by!(name: tech[:name].downcase.strip)
          end
        end
      end

      def handle_error(error)
        @job ||= user.jobs.build(job_attrs)
        @job.errors.add(:base, error.message)
        @job
      end
  end
end
