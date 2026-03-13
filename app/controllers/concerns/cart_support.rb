# frozen_string_literal: true

module CartSupport
  extend ActiveSupport::Concern

  CART_SESSION_KEY = :admin_cart
  CART_FREE_GIFTS_KEY = :admin_cart_free_gifts

  included do
    helper_method :cart_items, :cart_subtotal_cents, :cart_item_count, :cart_qualifying_combos
  end

  def cart
    session[CART_SESSION_KEY] ||= {}
  end

  def cart_free_gifts
    session[CART_FREE_GIFTS_KEY] ||= {}
  end

  def cart_item_count
    cart.values.sum + cart_free_gifts.values.sum
  end

  def cart_items
    items = []
    product_ids = (cart.keys + cart_free_gifts.keys).map(&:to_i).uniq
    products = Product.where(id: product_ids).index_by(&:id)

    cart.each do |product_id_str, qty|
      product = products[product_id_str.to_i]
      next unless product && qty.to_i.positive?

      items << { product: product, quantity: qty.to_i, is_free_gift: false }
    end

    cart_free_gifts.each do |product_id_str, qty|
      product = products[product_id_str.to_i]
      next unless product && qty.to_i.positive?

      items << { product: product, quantity: qty.to_i, is_free_gift: true }
    end

    items
  end

  def cart_subtotal_cents
    cart_items.sum do |item|
      item[:is_free_gift] ? 0 : item[:product].price * item[:quantity]
    end
  end

  def add_to_cart(product_id, quantity = 1, free_gift: false)
    id = product_id.to_s
    if free_gift
      cart_free_gifts[id] = (cart_free_gifts[id].to_i + quantity.to_i)
    else
      cart[id] = (cart[id].to_i + quantity.to_i)
    end
  end

  def update_cart_item(product_id, quantity, free_gift: false)
    id = product_id.to_s
    qty = quantity.to_i
    target = free_gift ? cart_free_gifts : cart
    if qty <= 0
      target.delete(id)
    else
      target[id] = qty
    end
  end

  def remove_from_cart(product_id, free_gift: false)
    if free_gift
      cart_free_gifts.delete(product_id.to_s)
    else
      cart.delete(product_id.to_s)
    end
  end

  def clear_cart
    session[CART_SESSION_KEY] = {}
    session[CART_FREE_GIFTS_KEY] = {}
  end

  # Returns qualifying product combos: [{ combo:, items: [{ product:, free_qty_to_add: }] }]
  def cart_qualifying_combos
    return [] if cart.blank?

    combos = ProductCombo.active.valid_now
                          .includes(product_combo_triggers: :product, product_combo_free_products: :product)
    result = []

    combos.each do |combo|
      cart_qty = cart.each_with_object({}) { |(k, v), h| h[k.to_i] = v.to_i }
      current_free = cart_free_gifts.each_with_object({}) { |(k, v), h| h[k.to_i] = v.to_i }
      items = combo.free_items_to_add(cart_qty, current_free)
      next if items.empty?

      # Filter out products with insufficient stock
      items = items.reject { |i| i[:product].stock_quantity < i[:free_qty_to_add] }
      next if items.empty?

      result << { combo: combo, items: items }
    end

    result
  end
end
