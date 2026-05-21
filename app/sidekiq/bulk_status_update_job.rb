# frozen_string_literal: true

class BulkStatusUpdateJob
  include Sidekiq::Job

  def perform(ids)
    JobApplication.where(id: ids).find_each do |job_application|
      send_response_mail(job_application)
    end
  end

  private

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
