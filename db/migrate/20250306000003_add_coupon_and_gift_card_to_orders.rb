# frozen_string_literal: true

class AddCouponAndGiftCardToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :coupon, null: true, foreign_key: true
    add_reference :orders, :gift_card, null: true, foreign_key: true
    add_column :orders, :discount_cents, :integer, default: 0, null: false
  end
end
