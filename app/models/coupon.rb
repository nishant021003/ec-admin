# frozen_string_literal: true

class Coupon < ApplicationRecord
  DISCOUNT_TYPES = %w[percentage fixed].freeze
  STATUSES = %w[active inactive].freeze

  has_many :coupon_usages, dependent: :destroy
  has_many :coupon_products, dependent: :destroy
  has_many :products, through: :coupon_products

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, presence: true, inclusion: { in: DISCOUNT_TYPES }
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :min_cart_value, numericality: { greater_than_or_equal_to: 0 }
  validates :usage_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :per_user_limit, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :normalize_code

  scope :active, -> { where(status: "active") }

  def active?
    status == "active"
  end

  def valid_for?(order_total_cents, user_id: nil, product_ids: nil)
    return false unless active?
    return false if start_date && Date.current < start_date
    return false if expiry_date && Date.current > expiry_date
    return false if min_cart_value.positive? && order_total_cents < min_cart_value
    return false if usage_limit && coupon_usages.count >= usage_limit
    if per_user_limit && user_id.present?
      return false if coupon_usages.where(user_id: user_id).count >= per_user_limit
    end
    return false if product_ids.present? && coupon_products.any? && (product_ids & coupon_products.pluck(:product_id)).empty?
    true
  end

  def discount_amount(order_total_cents, applicable_subtotal_cents: nil)
    return 0 if order_total_cents <= 0
    applicable = applicable_subtotal_cents || order_total_cents

    raw_discount = if discount_type == "percentage"
      (applicable * discount_value / 100.0).round
    else
      [discount_value, applicable].min
    end

    if discount_type == "percentage" && max_discount.present? && max_discount.positive?
      raw_discount = [raw_discount, max_discount].min
    end

    [raw_discount, order_total_cents].min
  end

  def discount_label
    if discount_type == "percentage"
      label = "#{discount_value}% off"
      label += " (max $#{'%.2f' % (max_discount / 100.0)})" if max_discount.present? && max_discount.positive?
      label
    else
      "$#{'%.2f' % (discount_value / 100.0)} off"
    end
  end

  def record_usage!(order:, user_id: nil, discount_amount:)
    coupon_usages.create!(
      order: order,
      user_id: user_id,
      discount_amount: discount_amount,
      used_at: Time.current
    )
  end

  private

  def normalize_code
    self.code = code.to_s.upcase.strip if code.present?
  end
end
