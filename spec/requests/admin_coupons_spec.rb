# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin coupons", type: :request do
  before { sign_in_admin }

  describe "GET /admin/coupons" do
    it "lists coupons" do
      create_list(:coupon, 2)
      get admin_coupons_path
      expect(response).to have_http_status(:ok)
    end

    it "shows coupon details" do
      coupon = create(:coupon, code: "SAVE50", discount_value: 50)
      get admin_coupon_path(coupon)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("SAVE50")
    end
  end

  describe "POST /admin/coupons" do
    it "renders new with errors when invalid" do
      post admin_coupons_path, params: { coupon: { code: "", discount_type: "invalid" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a coupon" do
      expect do
        post admin_coupons_path, params: {
          coupon: { code: "SAVE20", discount_type: "percentage", discount_value: 20, status: "active" }
        }
      end.to change(Coupon, :count).by(1)
      expect(response).to redirect_to(admin_coupon_path(Coupon.last))
    end
  end

  describe "PATCH /admin/coupons/:id" do
    it "renders edit with errors when invalid" do
      coupon = create(:coupon)
      patch admin_coupon_path(coupon), params: {
        coupon: { code: "", discount_type: "percentage", discount_value: -1 }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates a coupon" do
      coupon = create(:coupon, discount_value: 10)
      patch admin_coupon_path(coupon), params: {
        coupon: { code: coupon.code, discount_type: "percentage", discount_value: 15, status: "active" }
      }
      expect(coupon.reload.discount_value).to eq(15)
    end
  end

  describe "DELETE /admin/coupons/:id" do
    it "deletes a coupon" do
      coupon = create(:coupon)
      expect { delete admin_coupon_path(coupon) }.to change(Coupon, :count).by(-1)
    end
  end
end
