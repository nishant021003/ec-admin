# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderLineItem, type: :model do
  it "is valid with valid attributes" do
    item = build(:order_line_item)
    expect(item).to be_valid
  end

  it "requires quantity > 0" do
    item = build(:order_line_item, quantity: 0)
    expect(item).not_to be_valid
  end

  it "requires unit_price_cents >= 0" do
    item = build(:order_line_item, unit_price_cents: -1)
    expect(item).not_to be_valid
  end

  it "returns free_gift? correctly" do
    item = build(:order_line_item, is_free_gift: true)
    expect(item.free_gift?).to be true
  end

  it "belongs to order and product" do
    order = create(:order)
    product = create(:product)
    item = create(:order_line_item, order: order, product: product)
    expect(item.order).to eq(order)
    expect(item.product).to eq(product)
  end

  it "scopes free_gifts and paid_items" do
    order = create(:order)
    p1 = create(:product)
    p2 = create(:product)
    create(:order_line_item, order: order, product: p1, is_free_gift: true)
    create(:order_line_item, order: order, product: p2, is_free_gift: false)
    expect(order.order_line_items.free_gifts.count).to eq(1)
    expect(order.order_line_items.paid_items.count).to eq(1)
  end
end
