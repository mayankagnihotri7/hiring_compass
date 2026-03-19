# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.string :location
      t.string :status, null: false, default: "open"
      t.text :description, null: false
      t.integer :min_salary
      t.integer :max_salary
      t.string :currency, null: false, default: "USD"
      t.integer :years_of_experience, null: false, default: 0
      t.string :category, null: false

      t.timestamps
    end
  end
end
