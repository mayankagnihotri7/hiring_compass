# frozen_string_literal: true

class Job < ApplicationRecord
  enum status: %w[open closed paused].index_by(&:itself)

  validates :title, :status, :currency, presence: true
  validates :min_salary, :max_salary, numericality: { greater_than: 0 }
  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :max_salary_not_less_than_min_salary

  has_many :job_technologies
  has_many :technologies, through: :job_technologies

  belongs_to :user

  private

    def max_salary_not_less_than_min_salary
      return if min_salary.blank? || max_salary.blank?

      if min_salary > max_salary
        errors.add(:max_salary, "must be greater than or equal to min salary")
      end
    end
end
