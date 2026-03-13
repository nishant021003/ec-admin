# frozen_string_literal: true

module Admin
  class CartController < Admin::BaseController
    include CartSupport

    def index
      @cart_items = cart_items
      @subtotal_cents = cart_subtotal_cents
      @qualifying_combos = cart_qualifying_combos
    end

    def add
      product = Product.find(params[:product_id])
      free_gift = params[:free_gift].to_s == "1"
      if product.status != "active"
        redirect_back fallback_location: admin_products_path, alert: "Product is not available."
        return
      end
      if product.stock_quantity.zero?
        redirect_back fallback_location: admin_products_path, alert: "Product is out of stock."
        return
      end
      qty = [(params[:quantity].presence || 1).to_i, 1].max
      add_to_cart(product.id, qty, free_gift: free_gift)
      notice = free_gift ? "Added #{product.name} as free gift." : "Added #{product.name} to cart."
      redirect_to params[:return_to] == "cart" ? admin_cart_path : admin_product_path(product), notice: notice
    end

    def update
      product = Product.find(params[:product_id])
      free_gift = params[:free_gift].to_s == "1"
      qty = params[:quantity].to_i
      if qty <= 0
        remove_from_cart(product.id, free_gift: free_gift)
        redirect_to admin_cart_path, notice: "Removed #{product.name} from cart."
      else
        max_qty = free_gift ? 999 : product.stock_quantity
        qty = [qty, max_qty].min
        update_cart_item(product.id, qty, free_gift: free_gift)
        redirect_to admin_cart_path, notice: "Cart updated."
      end
    end

    def remove
      product = Product.find(params[:product_id])
      free_gift = params[:free_gift].to_s == "1"
      remove_from_cart(product.id, free_gift: free_gift)
      redirect_to admin_cart_path, notice: "Removed #{product.name} from cart."
    end
  end
end
