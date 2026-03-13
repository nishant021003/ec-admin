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

  it "scope search filters by name and description" do
    p1 = create(:product, name: "Apple Juice")
    p2 = create(:product, name: "X", description: "Apple flavor")
    create(:product, name: "Orange Soda")
    expect(Product.search("Apple")).to contain_exactly(p1, p2)
  end

  it "scope by_status filters by status" do
    p1 = create(:product, status: "active")
    create(:product, status: "draft")
    expect(Product.by_status("active")).to contain_exactly(p1)
  end

  it "scope low_stock returns products at or below threshold" do
    p1 = create(:product, stock_quantity: 3)
    create(:product, stock_quantity: 10)
    expect(Product.low_stock(5)).to contain_exactly(p1)
  end

  it "scope by_category filters by category" do
    cat = create(:category)
    p1 = create(:product)
    p1.categories << cat
    expect(Product.by_category(cat.id)).to include(p1)
  end

  it "scope price_between filters by price range" do
    p1 = create(:product, price: 500)
    create(:product, price: 2000)
    expect(Product.price_between(400, 600)).to contain_exactly(p1)
  end

  it "scope search returns all when query blank" do
    create_list(:product, 2)
    expect(Product.search(nil).count).to eq(2)
    expect(Product.search("").count).to eq(2)
  end
end
