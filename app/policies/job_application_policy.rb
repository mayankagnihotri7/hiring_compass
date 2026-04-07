# frozen_string_literal: true

class JobApplicationPolicy
  attr_reader :user, :job_application

  def initialize(user, job_application)
    @user = user
    @job_application = job_application
  end

  def create?
    job_application.job.open?
  end

  def update?
    job_application.job.user == user || user.admin?
  end

  def show?
    update?
  end

  def download?
    update?
  end
end
