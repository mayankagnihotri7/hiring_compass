# frozen_string_literal: true

class JobApplicationPolicy
  attr_reader :user, :job_application

  def initialize(user, job_application)
    @user = user
    @job_application = job_application
  end

  def update?
    job_application.job.user == user || user.admin?
  end
end
