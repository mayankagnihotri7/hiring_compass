# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable

  include DeviseTokenAuth::Concerns::User

  enum :role, %w[recruiter admin].index_by(&:itself)

  has_many :jobs

  before_validation :normalize_phone_number

  validates :first_name, :last_name, presence: true, format: { with: /\A[\p{L}\s'-]+\z/ }, length: { maximum: 20 }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :address, length: { maximum: 255 }, allow_blank: true
  validates :phone_number, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  private

    def normalize_phone_number
      return if phone_number.blank?

      parsed = Phonelib.parse(phone_number)

      self.phone_number = parsed.full_e164 if parsed.valid?
    end
end
