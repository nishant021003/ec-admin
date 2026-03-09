# frozen_string_literal: true

class CreateUsersRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :users_roles, id: false do |t|
      t.references :user, type: :bigint
      t.references :role, type: :bigint
    end

    add_index :users_roles, [:user_id, :role_id], unique: true
  end
end
