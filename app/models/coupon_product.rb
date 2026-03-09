# frozen_string_literal: true

class CouponProduct < ApplicationRecord
  belongs_to :coupon
  belongs_to :product

  validates :coupon_id, uniqueness: { scope: :product_id }
end
