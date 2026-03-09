# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin products", type: :request do
  let(:admin) { create(:user).tap { |u| u.add_role :admin } }
  let(:category) { create(:category) }

  before do
    post admin_login_path, params: { email: admin.email, password: "Password123!" }
  end

  describe "GET /admin/products" do
    it "lists products" do
      create_list(:product, 3)
      get admin_products_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/products" do
    it "creates a product" do
      expect {
        post admin_products_path, params: {
          product: { name: "New Product", price: 1000, status: "active", category_ids: [category.id] }
        }
      }.to change(Product, :count).by(1)
      expect(response).to redirect_to(admin_product_path(Product.last))
    end
  end

  describe "PATCH /admin/products/:id" do
    it "updates a product" do
      product = create(:product, name: "Old Name")
      patch admin_product_path(product), params: {
        product: { name: "New Name", price: product.price, status: product.status }
      }
      expect(product.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /admin/products/:id" do
    it "deletes a product" do
      product = create(:product)
      expect {
        delete admin_product_path(product)
      }.to change(Product, :count).by(-1)
    end
  end
end
