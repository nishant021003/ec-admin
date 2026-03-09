# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :user, optional: true
  belongs_to :coupon, optional: true
  belongs_to :gift_card, optional: true
  has_many :order_line_items, dependent: :destroy
  has_many :products, through: :order_line_items
  has_many :coupon_usages, dependent: :nullify
  has_many :gift_card_transactions, dependent: :nullify

  has_paper_trail

  STATUSES = %w[pending processing shipped delivered cancelled].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :coupon_discount, numericality: { greater_than_or_equal_to: 0 }
  validates :gift_card_discount, numericality: { greater_than_or_equal_to: 0 }
  validates :final_amount, numericality: { greater_than_or_equal_to: 0 }

  def subtotal_cents
    order_line_items.sum { |li| li.unit_price_cents * li.quantity }
  end
end
