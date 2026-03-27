# frozen_string_literal: true

class JobApplication < ApplicationRecord
  enum :status, %w[pending reviewed shortlisted rejected hired withdrawn].index_by(&:itself)

  belongs_to :job

  has_one_attached :resume

  validates :first_name, :last_name, :email, :years_of_experience, :status, presence: true
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def full_name
    "#{first_name} #{last_name}"
  end
end
