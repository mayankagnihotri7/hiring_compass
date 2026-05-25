# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkStatusUpdateJob, type: :job do
  describe "#perform_async" do
    let!(:user) { create(:user) }
    let!(:job) { create(:job, user: user) }
    let(:ids) { create_list(:job_application, 3, job: job).map(&:id) }

    before do
      allow_any_instance_of(JobApplication).to receive(:verify_otp).and_return(true)
    end

    it "enqueues the job" do
      expect {
         BulkStatusUpdateJob.perform_async(ids)
       }.to change(BulkStatusUpdateJob.jobs, :size).by(1)
    end
  end
end
