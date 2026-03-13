# frozen_string_literal: true

class CreateProductCombos < ActiveRecord::Migration[8.1]
  def change
    create_table :product_combos do |t|
      t.references :trigger_product, null: false, foreign_key: { to_table: :products }
      t.integer :trigger_quantity, null: false, default: 1
      t.references :free_product, null: false, foreign_key: { to_table: :products }
      t.integer :free_quantity, null: false, default: 1
      t.boolean :is_active, null: false, default: true
      t.date :valid_from
      t.date :valid_to

      t.timestamps
    end

    add_index :product_combos, :is_active
    add_index :product_combos, [:trigger_product_id, :free_product_id], unique: true,
              name: "index_product_combos_on_trigger_and_free"
  end
end
