# frozen_string_literal: true

class JobPolicy
  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job = job
  end

  def create?
    user.admin? || user.recruiter?
  end

  def update?
    job.user == user || user.admin?
  end

  def show?
    update?
  end

  def destroy?
    user.admin?
  end
end
