# frozen_string_literal: true

class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :discount_type, null: false, default: "percentage" # percentage or fixed
      t.integer :discount_value, null: false, default: 0
      t.integer :min_order_cents, default: 0
      t.integer :max_uses
      t.integer :times_used, default: 0, null: false
      t.datetime :valid_from
      t.datetime :valid_until
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
