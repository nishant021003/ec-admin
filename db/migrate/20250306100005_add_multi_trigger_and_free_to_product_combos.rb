# frozen_string_literal: true

class AddMultiTriggerAndFreeToProductCombos < ActiveRecord::Migration[8.1]
  def up
    create_table :product_combo_triggers do |t|
      t.references :product_combo, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    add_index :product_combo_triggers, [:product_combo_id, :product_id], unique: true,
              name: "index_product_combo_triggers_on_combo_and_product"

    create_table :product_combo_free_products do |t|
      t.references :product_combo, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    add_index :product_combo_free_products, [:product_combo_id, :product_id], unique: true,
              name: "index_product_combo_free_products_on_combo_and_product"

    # Migrate existing single trigger/free to new tables (if columns exist)
    if column_exists?(:product_combos, :trigger_product_id)
      execute <<-SQL.squish
        INSERT INTO product_combo_triggers (product_combo_id, product_id, quantity, created_at, updated_at)
        SELECT id, trigger_product_id, trigger_quantity, NOW(), NOW() FROM product_combos WHERE trigger_product_id IS NOT NULL
      SQL
      execute <<-SQL.squish
        INSERT INTO product_combo_free_products (product_combo_id, product_id, quantity, created_at, updated_at)
        SELECT id, free_product_id, free_quantity, NOW(), NOW() FROM product_combos WHERE free_product_id IS NOT NULL
      SQL

      remove_index :product_combos, name: "index_product_combos_on_trigger_and_free" if index_exists?(:product_combos, [:trigger_product_id, :free_product_id], name: "index_product_combos_on_trigger_and_free")
      remove_foreign_key :product_combos, :products, column: :trigger_product_id
      remove_foreign_key :product_combos, :products, column: :free_product_id
      remove_column :product_combos, :trigger_product_id
      remove_column :product_combos, :trigger_quantity
      remove_column :product_combos, :free_product_id
      remove_column :product_combos, :free_quantity
    end
  end

  def down
    add_reference :product_combos, :trigger_product, foreign_key: { to_table: :products }
    add_column :product_combos, :trigger_quantity, :integer, default: 1, null: false
    add_reference :product_combos, :free_product, foreign_key: { to_table: :products }
    add_column :product_combos, :free_quantity, :integer, default: 1, null: false

    # Copy first trigger/free back (lossy)
    execute <<-SQL.squish
      UPDATE product_combos pc SET trigger_product_id = (SELECT product_id FROM product_combo_triggers WHERE product_combo_id = pc.id LIMIT 1),
        trigger_quantity = (SELECT quantity FROM product_combo_triggers WHERE product_combo_id = pc.id LIMIT 1)
    SQL
    execute <<-SQL.squish
      UPDATE product_combos pc SET free_product_id = (SELECT product_id FROM product_combo_free_products WHERE product_combo_id = pc.id LIMIT 1),
        free_quantity = (SELECT quantity FROM product_combo_free_products WHERE product_combo_id = pc.id LIMIT 1)
    SQL

    drop_table :product_combo_free_products
    drop_table :product_combo_triggers
  end
end
