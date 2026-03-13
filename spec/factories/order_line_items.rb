# frozen_string_literal: true

FactoryBot.define do
  factory :order_line_item do
    association :order
    association :product
    quantity { 1 }
    unit_price_cents { 999 }
    is_free_gift { false }
  end
end
