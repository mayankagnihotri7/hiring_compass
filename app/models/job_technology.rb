# frozen_string_literal: true

class JobTechnology < ApplicationRecord
  belongs_to :job
  belongs_to :technology
end
