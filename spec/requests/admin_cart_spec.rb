# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin cart", type: :request do
  let(:product) { create(:product, status: "active", stock_quantity: 10) }

  before { sign_in_admin }

  describe "GET /admin/cart" do
    it "shows cart" do
      get admin_cart_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/cart/add/:product_id" do
    it "adds product to cart" do
      post admin_cart_add_path(product_id: product.id)
      expect(response).to redirect_to(admin_product_path(product))
      get admin_cart_path
      expect(response.body).to include(product.name)
    end

    it "adds as free gift when free_gift=1" do
      post admin_cart_add_path(product_id: product.id, free_gift: "1")
      expect(response).to redirect_to(admin_product_path(product))
    end

    it "redirects with alert when product inactive" do
      product.update!(status: "draft")
      post admin_cart_add_path(product_id: product.id)
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects with alert when out of stock" do
      product.update!(stock_quantity: 0)
      post admin_cart_add_path(product_id: product.id)
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "PATCH /admin/cart/update/:product_id" do
    before { post admin_cart_add_path(product_id: product.id) }

    it "updates free gift quantity" do
      post admin_cart_add_path(product_id: product.id, free_gift: "1")
      patch admin_cart_update_path(product_id: product.id), params: { quantity: 2, free_gift: "1" }
      expect(response).to redirect_to(admin_cart_path)
    end

    it "updates cart item quantity" do
      patch admin_cart_update_path(product_id: product.id), params: { quantity: 3 }
      expect(response).to redirect_to(admin_cart_path)
    end

    it "removes when quantity 0" do
      patch admin_cart_update_path(product_id: product.id), params: { quantity: 0 }
      expect(response).to redirect_to(admin_cart_path)
    end
  end

  describe "cart with qualifying combos" do
    it "shows qualifying combo offers when cart has trigger products" do
      trigger = create(:product, status: "active", stock_quantity: 5)
      free_prod = create(:product, status: "active", stock_quantity: 5)
      create(:product_combo, trigger_product: trigger, free_product: free_prod)
      post admin_cart_add_path(product_id: trigger.id)
      get admin_cart_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(trigger.name)
    end
  end

  describe "DELETE /admin/cart/remove/:product_id" do
    it "removes product from cart" do
      post admin_cart_add_path(product_id: product.id)
      delete admin_cart_remove_path(product_id: product.id)
      expect(response).to redirect_to(admin_cart_path)
    end
  end
end
