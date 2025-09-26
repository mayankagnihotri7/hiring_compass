# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  enum role: %w[recruiter admin].index_by(&:itself)

  validates :first_name, :last_name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/ }, length: { maximum: 20 }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :phone_number, phone: true, presence: true

  before_save :normalize_phone_number

  def full_name
    "#{first_name} #{last_name}"
  end

  private

    def normalize_phone_number
      self.phone_number = Phonelib.parse(phone_number).full_e164
    end
end
