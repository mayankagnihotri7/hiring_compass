# frozen_string_literal: true

class CreateTechnologies < ActiveRecord::Migration[7.2]
  def change
    create_table :technologies, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :technologies, :name, unique: true
  end
end
