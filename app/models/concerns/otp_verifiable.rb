# frozen_string_literal: true

module OtpVerifiable
  extend ActiveSupport::Concern

  class OtpCooldownError < StandardError; end
  class OtpRateLimitError < StandardError; end

  OTP_TTL = 15.minutes
  COOLDOWN_TTL = 60.seconds
  MAX_SENDS = 3
  RATE_WINDOW_TTL = 15.minutes

  included do
    attr_accessor :otp_code

    validate :verify_otp, on: :create
    after_create :clear_otp
  end

  class_methods do
    def generate_otp(email)
      raise OtpCooldownError if Rails.cache.exist?("otp_cooldown_#{email}")
      raise OtpRateLimitError if Rails.cache.read("otp_sends_#{email}").to_i >= MAX_SENDS

      code = Rails.cache.fetch("otp_#{email}", expires_in: OTP_TTL) do
        rand(100_000..999_999).to_s
      end

      Rails.cache.write("otp_cooldown_#{email}", 1, expires_in: COOLDOWN_TTL)

      if Rails.cache.exist?("otp_sends_#{email}")
        Rails.cache.increment("otp_sends_#{email}")
      else
        Rails.cache.write("otp_sends_#{email}", 1, expires_in: RATE_WINDOW_TTL)
      end

      code
    end
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

    def clear_otp
      Rails.cache.delete("otp_#{email}")
      Rails.cache.delete("otp_sends_#{email}")
      Rails.cache.delete("otp_cooldown_#{email}")
    end
end
