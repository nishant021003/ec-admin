# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:slug) { |n| "product-#{n}" }
    description { "A product description" }
    price { 999 }
    status { "active" }
    stock_quantity { 10 }
  end
end
