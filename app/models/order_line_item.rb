# frozen_string_literal: true

class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :free_gifts, -> { where(is_free_gift: true) }
  scope :paid_items, -> { where(is_free_gift: false) }

  def free_gift?
    is_free_gift
  end
end
