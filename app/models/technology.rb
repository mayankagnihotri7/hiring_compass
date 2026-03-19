# frozen_string_literal: true

class Technology < ApplicationRecord
  has_many :job_technologies, dependent: :destroy
  has_many :jobs, through: :job_technologies

  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\s\.\+\#]+\z/ }
end
