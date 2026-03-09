# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :customer, foreign_key: true, type: :bigint
      t.string :status, default: "pending"
      t.integer :total_cents, default: 0

      t.timestamps
    end
  end
end
