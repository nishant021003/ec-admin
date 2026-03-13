# frozen_string_literal: true

require "rails_helper"

RSpec.describe Customer, type: :model do
  it "is valid with valid attributes" do
    customer = build(:customer)
    expect(customer).to be_valid
  end

  it "requires name" do
    customer = build(:customer, name: nil)
    expect(customer).not_to be_valid
  end

  it "requires email" do
    customer = build(:customer, email: nil)
    expect(customer).not_to be_valid
  end

  it "requires unique email" do
    create(:customer, email: "test@example.com")
    customer = build(:customer, email: "test@example.com")
    expect(customer).not_to be_valid
  end

  it "normalizes email to lowercase" do
    customer = create(:customer, email: "TEST@Example.COM")
    expect(customer.email).to eq("test@example.com")
  end

  it "has many orders" do
    customer = create(:customer)
    create(:order, customer: customer)
    expect(customer.orders.count).to eq(1)
  end

  it "has secure password" do
    customer = Customer.new(name: "Test", email: "test@example.com", password: "Secret123!", password_confirmation: "Secret123!")
    expect(customer).to be_valid
  end
end
