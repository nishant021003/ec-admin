# frozen_string_literal: true

class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user, optional: true
  belongs_to :order, optional: true

  validates :discount_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :used_at, presence: true
end
