# frozen_string_literal: true

class RefactorCouponsGiftCardsOrders < ActiveRecord::Migration[8.0]
  def up
    # --- Coupons: add new columns, migrate data, remove old ---
    add_column :coupons, :max_discount, :integer
    add_column :coupons, :min_cart_value, :integer, default: 0, null: false
    add_column :coupons, :usage_limit, :integer
    add_column :coupons, :per_user_limit, :integer
    add_column :coupons, :start_date, :date
    add_column :coupons, :expiry_date, :date
    add_column :coupons, :status, :string, default: "active", null: false

    execute "UPDATE coupons SET min_cart_value = COALESCE(min_order_cents, 0), usage_limit = max_uses"
    execute "UPDATE coupons SET start_date = valid_from::date WHERE valid_from IS NOT NULL"
    execute "UPDATE coupons SET expiry_date = valid_until::date WHERE valid_until IS NOT NULL"
    execute "UPDATE coupons SET status = CASE WHEN active THEN 'active' ELSE 'inactive' END"

    remove_column :coupons, :min_order_cents, :integer
    remove_column :coupons, :max_uses, :integer
    remove_column :coupons, :times_used, :integer
    remove_column :coupons, :valid_from, :datetime
    remove_column :coupons, :valid_until, :datetime
    remove_column :coupons, :active, :boolean

    # --- Coupon usages ---
    create_table :coupon_usages do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.integer :discount_amount, default: 0, null: false
      t.datetime :used_at, null: false

      t.timestamps
    end

    # --- Coupon products (product-specific coupons) ---
    create_table :coupon_products do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
    add_index :coupon_products, [:coupon_id, :product_id], unique: true

    # --- Gift cards: rename columns ---
    rename_column :gift_cards, :initial_balance_cents, :initial_balance
    rename_column :gift_cards, :current_balance_cents, :balance
    rename_column :gift_cards, :expires_at, :expiry_date

    # --- Gift card transactions ---
    create_table :gift_card_transactions do |t|
      t.references :gift_card, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.integer :amount, default: 0, null: false
      t.string :transaction_type, null: false # debit or credit

      t.timestamps
    end

    # --- Orders: add new columns ---
    add_reference :orders, :user, foreign_key: true, null: true
    add_column :orders, :total_amount, :integer, default: 0, null: false
    add_column :orders, :coupon_discount, :integer, default: 0, null: false
    add_column :orders, :gift_card_discount, :integer, default: 0, null: false
    add_column :orders, :final_amount, :integer, default: 0, null: false

    # Migrate existing data
    execute <<-SQL
      UPDATE orders SET
        total_amount = COALESCE(total_cents + discount_cents, 0),
        coupon_discount = CASE WHEN coupon_id IS NOT NULL THEN discount_cents ELSE 0 END,
        gift_card_discount = CASE WHEN gift_card_id IS NOT NULL THEN discount_cents ELSE 0 END,
        final_amount = COALESCE(total_cents, 0);
    SQL

    remove_column :orders, :discount_cents, :integer
    remove_column :orders, :total_cents, :integer
  end

  def down
    add_column :orders, :total_cents, :integer, default: 0
    add_column :orders, :discount_cents, :integer, default: 0, null: false
    execute "UPDATE orders SET total_cents = final_amount, discount_cents = coupon_discount + gift_card_discount"
    remove_column :orders, :total_amount, :integer
    remove_column :orders, :coupon_discount, :integer
    remove_column :orders, :gift_card_discount, :integer
    remove_column :orders, :final_amount, :integer
    remove_reference :orders, :user, foreign_key: true

    drop_table :gift_card_transactions
    rename_column :gift_cards, :initial_balance, :initial_balance_cents
    rename_column :gift_cards, :balance, :current_balance_cents
    rename_column :gift_cards, :expiry_date, :expires_at

    drop_table :coupon_products
    drop_table :coupon_usages

    remove_column :coupons, :max_discount, :integer
    remove_column :coupons, :min_cart_value, :integer
    remove_column :coupons, :usage_limit, :integer
    remove_column :coupons, :per_user_limit, :integer
    remove_column :coupons, :start_date, :date
    remove_column :coupons, :expiry_date, :date
    remove_column :coupons, :status, :string

    add_column :coupons, :min_order_cents, :integer, default: 0
    add_column :coupons, :max_uses, :integer
    add_column :coupons, :times_used, :integer, default: 0, null: false
    add_column :coupons, :valid_from, :datetime
    add_column :coupons, :valid_until, :datetime
    add_column :coupons, :active, :boolean, default: true, null: false
  end
end
