# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin product combos", type: :request do
  let(:trigger_product) { create(:product, name: "Trigger Product") }
  let(:free_product) { create(:product, name: "Free Product") }

  before { sign_in_admin }

  describe "GET /admin/product_combos" do
    it "lists product combos" do
      create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      get admin_product_combos_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/product_combos" do
    it "creates a product combo" do
      expect {
        post admin_product_combos_path, params: {
          product_combo: {
            is_active: "true",
            trigger_product_ids: [trigger_product.id],
            free_product_ids: [free_product.id],
            trigger_quantity: 1,
            free_quantity: 1
          }
        }
      }.to change(ProductCombo, :count).by(1)
      expect(response).to redirect_to(admin_product_combo_path(ProductCombo.last))
      combo = ProductCombo.last
      expect(combo.product_combo_triggers.count).to eq(1)
      expect(combo.product_combo_free_products.count).to eq(1)
    end
  end

  describe "PATCH /admin/product_combos/:id" do
    it "updates a product combo" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      new_free = create(:product)
      patch admin_product_combo_path(combo), params: {
        product_combo: {
          is_active: "true",
          trigger_product_ids: [trigger_product.id],
          free_product_ids: [new_free.id],
          trigger_quantity: 1,
          free_quantity: 2
        }
      }
      expect(response).to redirect_to(admin_product_combo_path(combo))
      combo.reload
      expect(combo.product_combo_free_products.count).to eq(1)
      expect(combo.free_products).to contain_exactly(new_free)
    end
  end

  describe "DELETE /admin/product_combos/:id" do
    it "deletes a product combo" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      expect { delete admin_product_combo_path(combo) }.to change(ProductCombo, :count).by(-1)
    end
  end
end
