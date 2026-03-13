# frozen_string_literal: true

class AddIsFreeGiftToOrderLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_line_items, :is_free_gift, :boolean, default: false, null: false
  end
end
