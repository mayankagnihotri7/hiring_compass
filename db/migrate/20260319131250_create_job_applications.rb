# frozen_string_literal: true

class CreateJobApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :job_applications, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :years_of_experience, null: false
      t.references :job, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false
      t.string :phone_number
      t.boolean :visa_sponsorship_required, default: false, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
