# frozen_string_literal: true

require "rails_helper"

RSpec.describe Job, type: :model do
  describe "Validations" do
    subject { build(:job) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:currency) }
    it { should validate_numericality_of(:min_salary).is_greater_than(0) }
    it { should validate_numericality_of(:max_salary).is_greater_than(0) }

    context "custom validation: max_salary >= min_salary" do
      it "is valid when max_salary > min_salary" do
        job = build(:job, min_salary: 5000, max_salary: 10000)
        expect(job).to be_valid
      end

      it "is invalid when max_salary < min_salary" do
        job = build(:job, min_salary: 10000, max_salary: 5000)
        expect(job).not_to be_valid
        expect(job.errors[:max_salary]).to include("must be greater than or equal to min salary")
      end
    end
  end

  describe "Enums" do
    it "defines correct statuses" do
      expect(Job.statuses.keys).to contain_exactly("open", "closed", "paused")
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end
end
