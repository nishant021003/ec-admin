# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductCombo, type: :model do
  let(:trigger_product) { create(:product, name: "Trigger") }
  let(:free_product) { create(:product, name: "Free") }

  it "is valid with triggers and free products" do
    combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
    expect(combo).to be_valid
    expect(combo.product_combo_triggers.count).to eq(1)
    expect(combo.product_combo_free_products.count).to eq(1)
  end

  it "invalid without trigger products" do
    combo = build(:product_combo)
    combo.product_combo_triggers.destroy_all
    combo.product_combo_free_products.build(product: free_product, quantity: 1)
    combo.valid?
    expect(combo.errors[:base]).to include("At least one trigger product is required")
  end

  it "invalid without free products" do
    combo = ProductCombo.new(is_active: true)
    combo.product_combo_triggers.build(product: trigger_product, quantity: 1)
    combo.valid?
    expect(combo.errors[:base]).to include("At least one free product is required")
  end

  it "invalid when trigger and free product overlap" do
    combo = ProductCombo.new(is_active: true)
    combo.product_combo_triggers.build(product: trigger_product, quantity: 1)
    combo.product_combo_free_products.build(product: trigger_product, quantity: 1)
    combo.valid?
    expect(combo.errors[:base]).to include("A product cannot be both trigger and free in the same combo")
  end

  describe "#times_eligible" do
    it "returns 0 when cart lacks trigger quantity" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      combo.product_combo_triggers.first.update!(quantity: 2)
      cart = { trigger_product.id => 1 }
      expect(combo.times_eligible(cart)).to eq(0)
    end

    it "returns times when cart has enough trigger quantity" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      combo.product_combo_triggers.first.update!(quantity: 2)
      cart = { trigger_product.id => 5 }
      expect(combo.times_eligible(cart)).to eq(2)
    end

    it "returns 0 when inactive" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product, is_active: false)
      cart = { trigger_product.id => 2 }
      expect(combo.times_eligible(cart)).to eq(0)
    end

    it "returns 0 when past valid_to" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product, valid_to: 1.day.ago)
      cart = { trigger_product.id => 2 }
      expect(combo.times_eligible(cart)).to eq(0)
    end
  end

  describe "#free_items_for" do
    it "returns free products when eligible" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      combo.product_combo_triggers.first.update!(quantity: 1)
      combo.product_combo_free_products.first.update!(quantity: 2)
      cart = { trigger_product.id => 3 }
      items = combo.free_items_for(cart)
      expect(items.size).to eq(1)
      expect(items.first[:product]).to eq(free_product)
      expect(items.first[:quantity]).to eq(6)
    end
  end

  describe "#display_name" do
    it "returns formatted string" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      expect(combo.display_name).to include("Trigger").and include("Free")
    end
  end

  describe "#qualifiable?" do
    it "returns true when times_eligible positive" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      cart = { trigger_product.id => 2 }
      expect(combo.qualifiable?(cart)).to be true
    end

    it "returns false when times_eligible zero" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product)
      cart = {}
      expect(combo.qualifiable?(cart)).to be false
    end
  end

  describe "scopes" do
    it "active returns only active combos" do
      create(:product_combo, trigger_product: trigger_product, free_product: free_product, is_active: false)
      active = create(:product_combo, trigger_product: create(:product), free_product: create(:product), is_active: true)
      expect(ProductCombo.active).to eq([active])
    end

    it "valid_now filters by valid_from and valid_to" do
      combo = create(:product_combo, trigger_product: trigger_product, free_product: free_product,
        valid_from: 1.day.ago, valid_to: 1.day.from_now)
      expect(ProductCombo.valid_now).to include(combo)
    end
  end
end
