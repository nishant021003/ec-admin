# frozen_string_literal: true

module CartSupport
  extend ActiveSupport::Concern

  CART_SESSION_KEY = :admin_cart

  included do
    helper_method :cart_items, :cart_subtotal_cents, :cart_item_count
  end

  def cart
    session[CART_SESSION_KEY] ||= {}
  end

  def cart_item_count
    cart.values.sum
  end

  def cart_items
    return [] if cart.blank?

    product_ids = cart.keys.map(&:to_i)
    products = Product.where(id: product_ids).index_by(&:id)
    cart.map do |product_id_str, qty|
      product = products[product_id_str.to_i]
      next unless product

      { product: product, quantity: qty.to_i }
    end.compact
  end

  def cart_subtotal_cents
    cart_items.sum { |item| item[:product].price * item[:quantity] }
  end

  def add_to_cart(product_id, quantity = 1)
    id = product_id.to_s
    cart[id] = (cart[id].to_i + quantity.to_i)
  end

  def update_cart_item(product_id, quantity)
    id = product_id.to_s
    qty = quantity.to_i
    if qty <= 0
      cart.delete(id)
    else
      cart[id] = qty
    end
  end

  def remove_from_cart(product_id)
    cart.delete(product_id.to_s)
  end

  def clear_cart
    session[CART_SESSION_KEY] = {}
  end
end
