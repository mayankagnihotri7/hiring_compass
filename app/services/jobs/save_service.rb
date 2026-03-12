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
        @job.save!
        @job.technologies = resolve_technologies if params[:technologies].present?
        @job
      end
    rescue => e
      @job ||= user.jobs.build(job_attrs)
      @job.errors.add(:base, e.message)
      @job
    end

    private

      def job_attrs
        params.except(:technologies)
      end

      def resolve_technologies
        params[:technologies].map do |tech|
          tech[:id].present? ? Technology.find(tech[:id]) : Technology.create!(name: tech[:name].strip)
        end
      end
  end
end
