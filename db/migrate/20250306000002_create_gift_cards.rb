# frozen_string_literal: true

class CreateGiftCards < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_cards do |t|
      t.string :code, null: false
      t.integer :initial_balance_cents, null: false, default: 0
      t.integer :current_balance_cents, null: false, default: 0
      t.string :status, null: false, default: "active" # active, redeemed, expired
      t.datetime :expires_at

      t.timestamps
    end

    add_index :gift_cards, :code, unique: true
  end
end
