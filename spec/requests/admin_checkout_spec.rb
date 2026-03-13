# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin checkout", type: :request do
  let(:product) { create(:product, status: "active", stock_quantity: 10, price: 1000) }

  before do
    sign_in_admin
    post admin_cart_add_path(product_id: product.id)
  end

  describe "GET /admin/checkout" do
    it "shows checkout" do
      get admin_checkout_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects when cart empty" do
      delete admin_cart_remove_path(product_id: product.id)
      get admin_checkout_path
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to be_present
    end

    it "applies coupon when discount_code provided" do
      coupon = create(:coupon, code: "SAVE10", discount_type: "percentage", discount_value: 10)
      get admin_checkout_path(discount_type: "coupon", discount_code: coupon.code)
      expect(response).to have_http_status(:ok)
    end

    it "applies gift card when discount_code provided" do
      gc = create(:gift_card, code: "GIFT100", initial_balance: 5000)
      get admin_checkout_path(discount_type: "gift_card", discount_code: gc.code)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/checkout" do
    it "creates order" do
      expect { post admin_checkout_path }.to change(Order, :count).by(1)
      expect(response).to redirect_to(admin_order_path(Order.last))
      expect(flash[:notice]).to include("Order #")
      order = Order.last
      expect(order.order_line_items.count).to eq(1)
      expect(order.order_line_items.first.unit_price_cents).to eq(1000)
    end

    it "reduces product stock" do
      post admin_checkout_path
      expect(product.reload.stock_quantity).to eq(9)
    end

    it "clears cart after successful checkout" do
      post admin_checkout_path
      get admin_cart_path
      expect(response.body).not_to include(product.name)
    end

    it "redirects when cart empty" do
      delete admin_cart_remove_path(product_id: product.id)
      expect { post admin_checkout_path }.not_to change(Order, :count)
      expect(response).to redirect_to(admin_products_path)
    end

    it "creates order with coupon discount" do
      coupon = create(:coupon, code: "SAVE10", discount_type: "percentage", discount_value: 10)
      post admin_checkout_path, params: { discount_type: "coupon", discount_code: coupon.code }
      expect(response).to redirect_to(admin_order_path(Order.last))
      order = Order.last
      expect(order.coupon_id).to eq(coupon.id)
      expect(order.coupon_discount).to eq(100)
      expect(order.final_amount).to eq(900)
    end

    it "creates order with gift card discount" do
      gc = create(:gift_card, code: "GIFT500", initial_balance: 500)
      post admin_checkout_path, params: { discount_type: "gift_card", discount_code: gc.code }
      expect(response).to redirect_to(admin_order_path(Order.last))
      order = Order.last
      expect(order.gift_card_id).to eq(gc.id)
      expect(order.gift_card_discount).to eq(500)
      expect(order.final_amount).to eq(500)
    end

    it "redirects when apply discount button clicked" do
      post admin_checkout_path, params: { apply: "1", discount_type: "coupon", discount_code: "SAVE10" }
      expect(response).to redirect_to(admin_checkout_path(discount_type: "coupon", discount_code: "SAVE10"))
    end

    it "redirects with alert on insufficient stock" do
      product.update!(stock_quantity: 1)
      post admin_cart_add_path(product_id: product.id)
      product.update!(stock_quantity: 0)
      post admin_checkout_path
      expect(response).to redirect_to(admin_checkout_path)
      expect(flash[:alert]).to include("Failed to place order")
    end
  end
end
