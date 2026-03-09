# frozen_string_literal: true

require "rails_helper"

RSpec.describe Product, type: :model do
  it "is valid with valid attributes" do
    product = build(:product)
    expect(product).to be_valid
  end

  it "requires name" do
    product = build(:product, name: nil)
    expect(product).not_to be_valid
  end

  it "generates slug from name" do
    product = create(:product, name: "Test Product", slug: nil)
    expect(product.slug).to eq("test-product")
  end

  it "ensures unique slug" do
    create(:product, name: "Same Name")
    product2 = create(:product, name: "Same Name")
    expect(product2.slug).to eq("same-name-2")
  end

  it "requires price >= 0" do
    product = build(:product, price: -1)
    expect(product).not_to be_valid
  end
end
