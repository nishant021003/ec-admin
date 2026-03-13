# frozen_string_literal: true

require "rails_helper"

RSpec.describe Coupon, type: :model do
  it "is valid with valid attributes" do
    coupon = build(:coupon)
    expect(coupon).to be_valid
  end

  it "requires code" do
    coupon = build(:coupon, code: nil)
    expect(coupon).not_to be_valid
  end

  it "requires unique code" do
    create(:coupon, code: "SAVE10")
    coupon = build(:coupon, code: "SAVE10")
    expect(coupon).not_to be_valid
  end

  it "normalizes code to uppercase" do
    coupon = create(:coupon, code: "save10")
    expect(coupon.code).to eq("SAVE10")
  end

  it "validates discount_type inclusion" do
    coupon = build(:coupon, discount_type: "invalid")
    expect(coupon).not_to be_valid
  end

  it "validates discount_value >= 0" do
    coupon = build(:coupon, discount_value: -1)
    expect(coupon).not_to be_valid
  end

  describe "#active?" do
    it "returns true when status is active" do
      expect(build(:coupon, status: "active").active?).to be true
    end

    it "returns false when status is inactive" do
      expect(build(:coupon, status: "inactive").active?).to be false
    end
  end

  describe "#valid_for?" do
    let(:coupon) { create(:coupon, status: "active", min_cart_value: 1000) }

    it "returns false when order total below min_cart_value" do
      expect(coupon.valid_for?(500)).to be false
    end

    it "returns true when order meets min_cart_value" do
      expect(coupon.valid_for?(1500)).to be true
    end

    it "returns false when coupon is inactive" do
      coupon.update!(status: "inactive")
      expect(coupon.valid_for?(1500)).to be false
    end

    it "returns false when past expiry_date" do
      coupon.update!(expiry_date: 1.day.ago)
      expect(coupon.valid_for?(1500)).to be false
    end
  end

  describe "#discount_amount" do
    it "calculates percentage discount" do
      coupon = create(:coupon, discount_type: "percentage", discount_value: 10)
      expect(coupon.discount_amount(1000)).to eq(100)
    end

    it "calculates fixed discount" do
      coupon = create(:coupon, discount_type: "fixed", discount_value: 500)
      expect(coupon.discount_amount(1000)).to eq(500)
    end

    it "caps fixed discount at order total" do
      coupon = create(:coupon, discount_type: "fixed", discount_value: 1500)
      expect(coupon.discount_amount(1000)).to eq(1000)
    end

    it "applies max_discount for percentage" do
      coupon = create(:coupon, discount_type: "percentage", discount_value: 50, max_discount: 200)
      expect(coupon.discount_amount(1000)).to eq(200)
    end

    it "returns 0 when order_total <= 0" do
      coupon = create(:coupon)
      expect(coupon.discount_amount(0)).to eq(0)
      expect(coupon.discount_amount(-100)).to eq(0)
    end

    it "uses applicable_subtotal_cents when provided" do
      coupon = create(:coupon, discount_type: "percentage", discount_value: 10)
      expect(coupon.discount_amount(1000, applicable_subtotal_cents: 500)).to eq(50)
    end
  end

  describe "#discount_label" do
    it "returns percentage label" do
      coupon = create(:coupon, discount_type: "percentage", discount_value: 15)
      expect(coupon.discount_label).to include("15%")
    end

    it "returns fixed label" do
      coupon = create(:coupon, discount_type: "fixed", discount_value: 500)
      expect(coupon.discount_label).to include("5.00")
    end

    it "includes max_discount for percentage" do
      coupon = create(:coupon, discount_type: "percentage", discount_value: 50, max_discount: 200)
      expect(coupon.discount_label).to include("max")
    end
  end

  describe "#valid_for? usage_limit and product_ids" do
    it "returns false when usage_limit exceeded" do
      coupon = create(:coupon, status: "active", usage_limit: 1)
      order = create(:order)
      coupon.record_usage!(order: order, discount_amount: 10)
      expect(coupon.valid_for?(1000)).to be false
    end

    it "returns false when before start_date" do
      coupon = create(:coupon, status: "active", start_date: 1.day.from_now)
      expect(coupon.valid_for?(1000)).to be false
    end

    it "returns false when product_ids restriction and no match" do
      coupon = create(:coupon, status: "active")
      p1 = create(:product)
      coupon.products << p1
      expect(coupon.valid_for?(1000, product_ids: [999])).to be false
    end

    it "returns true when product_ids match" do
      coupon = create(:coupon, status: "active")
      p1 = create(:product)
      coupon.products << p1
      expect(coupon.valid_for?(1000, product_ids: [p1.id])).to be true
    end

    it "returns false when per_user_limit exceeded" do
      coupon = create(:coupon, status: "active", per_user_limit: 1)
      user = create(:user)
      order = create(:order, user: user)
      coupon.record_usage!(order: order, user_id: user.id, discount_amount: 10)
      expect(coupon.valid_for?(1000, user_id: user.id)).to be false
    end
  end

  describe "#record_usage!" do
    it "creates coupon_usage" do
      coupon = create(:coupon)
      order = create(:order)
      expect { coupon.record_usage!(order: order, discount_amount: 100) }.to change(CouponUsage, :count).by(1)
      usage = coupon.coupon_usages.last
      expect(usage.discount_amount).to eq(100)
      expect(usage.order).to eq(order)
    end
  end
end
