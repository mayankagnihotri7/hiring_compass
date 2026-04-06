# frozen_string_literal: true

class Job < ApplicationRecord
  enum :status, %w[open closed paused].index_by(&:itself)
  enum :category, %w[tech sales marketing design product finance operations].index_by(&:itself)

  validates :title, :status, :currency, :category, :company_name, presence: true
  validates :min_salary, :max_salary, numericality: { greater_than: 0 }
  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :max_salary_not_less_than_min_salary
  validate :tech_job_must_have_technologies

  has_many :job_technologies
  has_many :technologies, through: :job_technologies
  has_many :job_applications, dependent: :destroy

  belongs_to :user
  # rubocop:disable Layout/LineLength
  scope :search_by_text, ->(query) { where("title ILIKE ? OR company_name ILIKE ?", "%#{query}%", "%#{query}%") if query.present? }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_technology, ->(tech_name) { joins(:technologies).where("technologies.name ILIKE ?", "%#{tech_name}%") if tech_name.present? }
  scope :by_experience, ->(years) { where("years_of_experience <= ?", years) if years.present? }
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :by_status, ->(status_name) { where(status: status_name) if status_name.present? }
  scope :by_min_salary, ->(min_salary) { where("min_salary >= ?", min_salary) if min_salary.present? }
  scope :by_max_salary, ->(max_salary) { where("max_salary <= ?", max_salary) if max_salary.present? }

  private

    def max_salary_not_less_than_min_salary
      return if min_salary.blank? || max_salary.blank?

      if min_salary > max_salary
        errors.add(:max_salary, "must be greater than or equal to min salary")
      end
    end

    def tech_job_must_have_technologies
      return unless category == "tech"
      return if technologies.any?

      errors.add(:technologies, "must be present for tech jobs")
    end
end
