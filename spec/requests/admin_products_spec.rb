# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin products", type: :request do
  let(:category) { create(:category) }

  before { sign_in_admin }

  describe "GET /admin/products/:id" do
    it "shows product details" do
      product = create(:product, name: "Widget Pro")
      get admin_product_path(product)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Widget Pro")
    end
  end

  describe "GET /admin/products" do
    it "lists products" do
      create_list(:product, 3)
      get admin_products_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by search" do
      create(:product, name: "Apple")
      get admin_products_path(q: "Apple")
      expect(response).to have_http_status(:ok)
    end

    it "filters by status and category" do
      cat = create(:category)
      get admin_products_path(status: "active", category_id: cat.id)
      expect(response).to have_http_status(:ok)
    end

    it "filters by price range" do
      get admin_products_path(min_price: 100, max_price: 500)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/products" do
    it "renders new with errors when invalid" do
      post admin_products_path, params: { product: { name: "", price: -1 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

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
    it "renders edit with errors when invalid" do
      product = create(:product)
      patch admin_product_path(product), params: { product: { name: "", price: -1 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

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
      expect { delete admin_product_path(product) }.to change(Product, :count).by(-1)
    end

    it "redirects with alert when product has order line items" do
      product = create(:product)
      order = create(:order)
      create(:order_line_item, order: order, product: product)
      delete admin_product_path(product)
      expect(response).to redirect_to(admin_product_path(product))
      expect(flash[:alert]).to include("Cannot delete")
    end
  end

  describe "GET export" do
    it "exports products as CSV" do
      get export_admin_products_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("id,name,slug")
    end
  end

  describe "POST bulk_action" do
    it "bulk updates status" do
      p1 = create(:product, status: "draft")
      p2 = create(:product, status: "draft")
      post bulk_action_admin_products_path, params: {
        product_ids: [p1.id, p2.id],
        bulk_action: "update",
        bulk_status: "active"
      }
      expect(p1.reload.status).to eq("active")
      expect(p2.reload.status).to eq("active")
    end

    it "bulk deletes products" do
      p1 = create(:product)
      p2 = create(:product)
      expect do
        post bulk_action_admin_products_path, params: {
          product_ids: [p1.id, p2.id],
          bulk_action: "destroy"
        }
      end.to change(Product, :count).by(-2)
    end

    it "redirects with alert when no products selected" do
      post bulk_action_admin_products_path, params: { product_ids: [], bulk_action: "update" }
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects with alert for invalid action" do
      p1 = create(:product)
      post bulk_action_admin_products_path, params: { product_ids: [p1.id], bulk_action: "invalid" }
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to eq("Invalid action.")
    end

    it "redirects when bulk update without status" do
      p1 = create(:product)
      post bulk_action_admin_products_path, params: { product_ids: [p1.id], bulk_action: "update" }
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to include("Select a status")
    end
  end

  describe "POST import" do
    it "redirects with alert when no file" do
      post import_admin_products_path
      expect(response).to redirect_to(admin_products_path)
      expect(flash[:alert]).to include("Please select")
    end

    it "imports from CSV when file provided" do
      create(:category, name: "Cat1")
      csv = Rack::Test::UploadedFile.new(
        StringIO.new("name,description,price,status,stock_quantity,categories\nP1,Desc,100,draft,5,Cat1"),
        "text/csv",
        original_filename: "products.csv"
      )
      post import_admin_products_path, params: { file: csv }
      expect(response).to redirect_to(admin_products_path)
      expect(Product.find_by(name: "P1")).to be_present
    end
  end
end
