# frozen_string_literal: true

class JobApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      elsif User.roles.include?(user.role)
        scope.joins(:job).where(jobs: { user: user })
      else
        raise Pundit::NotAuthorizedError, "not authorized to perform this action."
      end
    end

    attr_reader :user, :scope
  end

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

  def bulk_update_status?
    update?
  end
end
