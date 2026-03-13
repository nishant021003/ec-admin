# frozen_string_literal: true

class EnsureProductCombosNoLegacyColumns < ActiveRecord::Migration[8.1]
  def up
    return unless column_exists?(:product_combos, :trigger_product_id)

    if index_exists?(:product_combos, [:trigger_product_id, :free_product_id], name: "index_product_combos_on_trigger_and_free")
      remove_index :product_combos, name: "index_product_combos_on_trigger_and_free"
    end
    remove_foreign_key :product_combos, :products, column: :trigger_product_id if foreign_key_exists?(:product_combos, column: :trigger_product_id)
    remove_foreign_key :product_combos, :products, column: :free_product_id if foreign_key_exists?(:product_combos, column: :free_product_id)
    remove_column :product_combos, :trigger_product_id
    remove_column :product_combos, :trigger_quantity
    remove_column :product_combos, :free_product_id
    remove_column :product_combos, :free_quantity
  end

  def down
    # No-op - we don't restore legacy columns
  end
end
