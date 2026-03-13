# frozen_string_literal: true

class ProductCombo < ApplicationRecord
  has_many :product_combo_triggers, dependent: :destroy
  has_many :trigger_products, through: :product_combo_triggers, source: :product
  has_many :product_combo_free_products, dependent: :destroy
  has_many :free_products, through: :product_combo_free_products, source: :product

  accepts_nested_attributes_for :product_combo_triggers, allow_destroy: true, reject_if: proc { |a| a[:product_id].blank? }
  accepts_nested_attributes_for :product_combo_free_products, allow_destroy: true, reject_if: proc { |a| a[:product_id].blank? }

  validate :has_triggers_and_free_products
  validate :no_overlap_between_trigger_and_free

  scope :active, -> { where(is_active: true) }
  scope :valid_now, -> {
    scope = all
    scope = scope.where("valid_from IS NULL OR valid_from <= ?", Date.current)
    scope = scope.where("valid_to IS NULL OR valid_to >= ?", Date.current)
    scope
  }

  # Cart quantities: { product_id => qty } for paid items
  # Returns times this combo applies (min over triggers of cart_qty/trigger_qty)
  def times_eligible(cart_quantities)
    return 0 unless is_active
    return 0 if valid_from && Date.current < valid_from
    return 0 if valid_to && Date.current > valid_to
    return 0 if product_combo_triggers.empty?

    times = product_combo_triggers.map do |tr|
      cart_qty = cart_quantities[tr.product_id].to_i
      (cart_qty / tr.quantity).floor
    end
    times.min
  end

  # Returns [{ product:, quantity: }] for free items to add
  def free_items_for(cart_quantities)
    times = times_eligible(cart_quantities)
    return [] if times <= 0

    product_combo_free_products.map do |fp|
      { product: fp.product, quantity: times * fp.quantity }
    end
  end

  # For cart display: returns [{ product:, free_qty_to_add: }] - qty user can still add
  def free_items_to_add(cart_quantities, current_free_quantities)
    items = free_items_for(cart_quantities)
    items.map do |item|
      current = current_free_quantities[item[:product].id].to_i
      to_add = [item[:quantity] - current, 0].max
      next if to_add <= 0

      { product: item[:product], free_qty_to_add: to_add }
    end.compact
  end

  def display_name
    trigger_part = product_combo_triggers.map { |t| "#{t.quantity}× #{t.product.name}" }.join(" + ")
    free_part = product_combo_free_products.map { |f| "#{f.quantity}× #{f.product.name}" }.join(" + ")
    "Buy #{trigger_part} → get #{free_part} free"
  end

  def qualifiable?(cart_quantities)
    times_eligible(cart_quantities).positive?
  end

  private

  def has_triggers_and_free_products
    triggers = product_combo_triggers.reject { |t| t.marked_for_destruction? || t.product_id.blank? }
    free = product_combo_free_products.reject { |f| f.marked_for_destruction? || f.product_id.blank? }
    errors.add(:base, "At least one trigger product is required") if triggers.empty?
    errors.add(:base, "At least one free product is required") if free.empty?
  end

  def no_overlap_between_trigger_and_free
    trigger_ids = product_combo_triggers.reject { |t| t.marked_for_destruction? }.map(&:product_id).compact
    free_ids = product_combo_free_products.reject { |f| f.marked_for_destruction? }.map(&:product_id).compact
    overlap = trigger_ids & free_ids
    return if overlap.empty?

    errors.add(:base, "A product cannot be both trigger and free in the same combo")
  end
end
