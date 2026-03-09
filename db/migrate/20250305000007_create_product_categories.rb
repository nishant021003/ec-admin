# frozen_string_literal: true

class CreateProductCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true, type: :bigint
      t.references :category, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end

    add_index :product_categories, [:product_id, :category_id], unique: true
  end
end
