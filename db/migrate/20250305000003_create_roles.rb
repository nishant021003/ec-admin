# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :resource, polymorphic: true, type: :bigint

      t.timestamps
    end

    add_index :roles, [:name, :resource_type, :resource_id], unique: true
  end
end
