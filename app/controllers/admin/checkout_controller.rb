# frozen_string_literal: true

module Admin
  class CheckoutController < Admin::BaseController
    include CartSupport

    before_action :ensure_cart_not_empty, only: %i[index create]

    def index
      @cart_items = cart_items
      @subtotal_cents = cart_subtotal_cents
      @discount_cents = 0
      @applied_coupon = nil
      @applied_gift_card = nil
      discount_type = params[:discount_type].presence || (params[:discount_code].present? && params[:discount_type] != "gift_card" ? "coupon" : "gift_card")

      product_ids = @cart_items.map { |i| i[:product].id }

      if discount_type == "coupon" && params[:discount_code].present?
        coupon = Coupon.find_by("UPPER(code) = ?", params[:discount_code].to_s.strip.upcase)
        if coupon&.valid_for?(@subtotal_cents, user_id: current_user&.id, product_ids: product_ids)
          @applied_coupon = coupon
          @discount_cents = coupon.discount_amount(@subtotal_cents)
        end
      elsif discount_type == "gift_card" && params[:discount_code].present?
        gift_card = GiftCard.find_by("UPPER(code) = ?", params[:discount_code].to_s.strip.upcase)
        if gift_card&.redeemable?
          @applied_gift_card = gift_card
          @discount_cents = gift_card.apply_amount(@subtotal_cents)
        end
      end

      @total_cents = [@subtotal_cents - @discount_cents, 0].max
    end

    def create
      if params[:apply]
        redirect_to admin_checkout_path(discount_type: params[:discount_type], discount_code: params[:discount_code])
        return
      end

      discount_type = params[:discount_type].presence
      discount_code = params[:discount_code].to_s.strip

      coupon = nil
      gift_card = nil
      if discount_type == "coupon" && discount_code.present?
        coupon = Coupon.find_by("UPPER(code) = ?", discount_code.upcase)
      elsif discount_type == "gift_card" && discount_code.present?
        gift_card = GiftCard.find_by("UPPER(code) = ?", discount_code.upcase)
      end

      subtotal_cents = cart_subtotal_cents
      coupon_discount_cents = 0
      gift_card_discount_cents = 0
      product_ids = cart_items.map { |i| i[:product].id }

      if coupon&.valid_for?(subtotal_cents, user_id: current_user&.id, product_ids: product_ids)
        coupon_discount_cents = coupon.discount_amount(subtotal_cents)
      elsif gift_card&.redeemable?
        gift_card_discount_cents = gift_card.apply_amount(subtotal_cents)
      end

      final_amount_cents = [subtotal_cents - coupon_discount_cents - gift_card_discount_cents, 0].max

      order = Order.new(
        customer_id: nil,
        user_id: current_user&.id,
        status: "pending",
        total_amount: subtotal_cents,
        coupon_discount: coupon_discount_cents,
        gift_card_discount: gift_card_discount_cents,
        final_amount: final_amount_cents,
        coupon_id: coupon&.id,
        gift_card_id: gift_card&.id
      )

      Order.transaction do
        order.save!
        cart_items.each do |item|
          product = item[:product]
          qty = item[:quantity]
          free_gift = item[:is_free_gift]
          raise "Insufficient stock" if product.stock_quantity < qty

          order.order_line_items.create!(
            product: product,
            quantity: qty,
            unit_price_cents: free_gift ? 0 : product.price,
            is_free_gift: free_gift
          )
          product.update_column(:stock_quantity, product.stock_quantity - qty)
        end

        coupon&.record_usage!(order: order, user_id: current_user&.id, discount_amount: coupon_discount_cents)
        if gift_card && gift_card_discount_cents.positive?
          gift_card.deduct!(gift_card_discount_cents, order: order)
        end

        clear_cart
      end

      redirect_to admin_order_path(order), notice: "Order ##{order.id} placed successfully."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_checkout_path, alert: "Failed to place order: #{e.message}"
    rescue StandardError => e
      redirect_to admin_checkout_path, alert: "Failed to place order: #{e.message}"
    end

    private

    def ensure_cart_not_empty
      return if cart_item_count.positive?

      redirect_to admin_products_path, alert: "Your cart is empty. Add products first."
    end
  end
end
