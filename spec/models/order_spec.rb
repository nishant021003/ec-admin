# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  it "is valid with valid attributes" do
    order = build(:order)
    expect(order).to be_valid
  end

  it "validates status inclusion" do
    order = build(:order, status: "invalid")
    expect(order).not_to be_valid
  end

  it "accepts valid statuses" do
    %w[pending processing shipped delivered cancelled].each do |status|
      order = build(:order, status: status)
      expect(order).to be_valid
    end
  end

  it "validates total_amount >= 0" do
    order = build(:order, total_amount: -1)
    expect(order).not_to be_valid
  end

  it "calculates subtotal_cents from line items" do
    order = create(:order, total_amount: 0, final_amount: 0)
    p1 = create(:product, price: 500)
    p2 = create(:product, price: 300)
    create(:order_line_item, order: order, product: p1, quantity: 2, unit_price_cents: 500)
    create(:order_line_item, order: order, product: p2, quantity: 1, unit_price_cents: 300)
    expect(order.subtotal_cents).to eq(1300)
  end

  it "has paper trail" do
    order = create(:order)
    expect(order.respond_to?(:versions)).to be true
  end
end
