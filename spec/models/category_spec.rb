# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  it "is valid with valid attributes" do
    category = build(:category)
    expect(category).to be_valid
  end

  it "requires name" do
    category = build(:category, name: nil)
    expect(category).not_to be_valid
  end

  it "generates slug from name" do
    category = create(:category, name: "Test Category", slug: nil)
    expect(category.slug).to eq("test-category")
  end

  it "validates position as integer" do
    category = build(:category, position: 0)
    expect(category).to be_valid
  end

  it "ensures unique slug" do
    create(:category, name: "Same Name")
    cat2 = create(:category, name: "Same Name")
    expect(cat2.slug).to eq("same-name-2")
  end

  it "belongs to optional parent" do
    parent = create(:category)
    child = create(:category, parent: parent)
    expect(child.parent).to eq(parent)
    expect(parent.children).to include(child)
  end
end
