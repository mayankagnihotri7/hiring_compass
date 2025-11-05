# frozen_string_literal: true

class JobTechnology < ApplicationRecord
  belongs_to :job
  belongs_to :technology

  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
