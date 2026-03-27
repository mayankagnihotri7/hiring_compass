# frozen_string_literal: true

class JobApplicationMailer < ApplicationMailer
  def application_received(job_application)
    @job_application = job_application
    @company_name = job_application.job.company_name
    @job_title = job_application.job.title

    mail(to: @job_application.email, subject: "Application Received - #{@company_name}")
  end

  def application_reviewed(job_application)
    @job_application = job_application
    @company_name = job_application.job.company_name

    mail(to: @job_application.email, subject: "Application Under Review - #{@company_name}")
  end

  def application_shortlisted(job_application)
    @job_application = job_application
    @company_name = job_application.job.company_name

    mail(to: @job_application.email, subject: "Good News! You've been shortlisted - #{@company_name}")
  end

  def application_rejected(job_application)
    @job_application = job_application
    @company_name = job_application.job.company_name

    mail(to: @job_application.email, subject: "Application Update - #{@company_name}")
  end

  def application_hired(job_application)
    @job_application = job_application
    @company_name = job_application.job.company_name

    mail(to: @job_application.email, subject: "Congratulations! Offer from #{@company_name}")
  end
end
