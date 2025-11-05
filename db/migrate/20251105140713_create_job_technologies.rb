class CreateJobTechnologies < ActiveRecord::Migration[7.2]
  def change
    create_table :job_technologies, id: :uuid do |t|
      t.references :job, null: false, foreign_key: true, type: :uuid
      t.references :technology, null: false, foreign_key: true, type: :uuid
      t.integer :years_of_experience, null: false, default: 0

      t.timestamps
    end

    add_index :job_technologies, [:job_id, :technology_id], unique: true
  end
end
