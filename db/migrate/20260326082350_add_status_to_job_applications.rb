# frozen_string_literal: true

class AddStatusToJobApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :status, :string, null: false, default: "pending"
  end
end
