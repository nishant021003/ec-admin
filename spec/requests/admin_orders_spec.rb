# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin orders", type: :request do
  before { sign_in_admin }

  describe "GET /admin/orders" do
    it "lists orders" do
      create_list(:order, 2)
      get admin_orders_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/orders/:id" do
    it "shows order details" do
      order = create(:order)
      get admin_order_path(order)
      expect(response).to have_http_status(:ok)
    end

    it "shows order with line items" do
      order = create(:order)
      product = create(:product)
      create(:order_line_item, order: order, product: product, quantity: 2, unit_price_cents: 500)
      get admin_order_path(order)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end
  end

  describe "PATCH /admin/orders/:id" do
    it "updates order status" do
      order = create(:order, status: "pending")
      patch admin_order_path(order), params: { order: { status: "processing" } }
      expect(order.reload.status).to eq("processing")
    end

    it "redirects with alert for invalid status" do
      order = create(:order)
      patch admin_order_path(order), params: { order: { status: "invalid" } }
      expect(response).to redirect_to(admin_order_path(order))
      expect(flash[:alert]).to eq("Invalid status.")
    end
  end

  describe "GET export" do
    it "exports orders as CSV" do
      get export_admin_orders_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("id,customer_name")
    end

    it "exports order data in CSV rows" do
      order = create(:order)
      get export_admin_orders_path
      expect(response.body).to include(order.id.to_s)
    end
  end
end
