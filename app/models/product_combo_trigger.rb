# frozen_string_literal: true

class ProductComboTrigger < ApplicationRecord
  belongs_to :product_combo
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :product_combo_id }
end
