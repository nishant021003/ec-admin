# frozen_string_literal: true

class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
end
