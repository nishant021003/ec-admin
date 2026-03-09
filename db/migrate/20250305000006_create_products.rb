# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :price, default: 0
      t.string :status, default: "draft"

      t.timestamps
    end

    add_index :products, :slug, unique: true
  end
end
