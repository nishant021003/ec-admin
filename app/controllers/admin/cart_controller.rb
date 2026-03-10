# frozen_string_literal: true

module Admin
  class CartController < Admin::BaseController
    include CartSupport

    def index
      @cart_items = cart_items
      @subtotal_cents = cart_subtotal_cents
    end

    def add
      product = Product.find(params[:product_id])
      if product.status != "active"
        redirect_back fallback_location: admin_products_path, alert: "Product is not available."
        return
      end
      if product.stock_quantity.zero?
        redirect_back fallback_location: admin_products_path, alert: "Product is out of stock."
        return
      end
      qty = [(params[:quantity].presence || 1).to_i, 1].max
      add_to_cart(product.id, qty)
      redirect_to admin_product_path(product), notice: "Added #{product.name} to cart."
    end

    def update
      product = Product.find(params[:product_id])
      qty = params[:quantity].to_i
      if qty <= 0
        remove_from_cart(product.id)
        redirect_to admin_cart_path, notice: "Removed #{product.name} from cart."
      else
        qty = [qty, product.stock_quantity].min
        update_cart_item(product.id, qty)
        redirect_to admin_cart_path, notice: "Cart updated."
      end
    end

    def remove
      product = Product.find(params[:product_id])
      remove_from_cart(product.id)
      redirect_to admin_cart_path, notice: "Removed #{product.name} from cart."
    end
  end
end
