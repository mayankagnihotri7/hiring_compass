# frozen_string_literal: true

class JobApplication < ApplicationRecord
  ACCEPTED_CONTENT_TYPES = ["application/pdf", "application/msword"].freeze

  enum :status, %w[pending reviewed shortlisted rejected hired withdrawn].index_by(&:itself)
  attr_accessor :otp_code

  belongs_to :job

  has_one_attached :resume

  validates :first_name, :last_name, :email, :years_of_experience, :status, presence: true
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :resume, content_type: ACCEPTED_CONTENT_TYPES,
    size: { less_than: 1.megabyte, message: "must be less than 1MB" }, attached: true, on: :create
  validate :verify_otp, on: :create

  def self.generate_otp(email)
    code = rand(100_000..999_9999).to_s

    Rails.cache.write("otp_#{email}", code, expires_in: 15.minutes)

    code
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

    def verify_otp
      return if email.blank?

      cached_code = Rails.cache.read("otp_#{email}")

      if cached_code.nil?
        errors.add(:otp_code, "has expired. Please request a new one.")
      elsif cached_code != otp_code
        errors.add(:otp_code, "is incorrect")
      end
    end
end
