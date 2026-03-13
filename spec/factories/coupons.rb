# frozen_string_literal: true

FactoryBot.define do
  factory :coupon do
    sequence(:code) { |n| "COUPON#{n}" }
    discount_type { "percentage" }
    discount_value { 10 }
    status { "active" }
    min_cart_value { 0 }
  end
end
