# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :customer
    status { "pending" }
    total_amount { 0 }
    coupon_discount { 0 }
    gift_card_discount { 0 }
    final_amount { 0 }
  end
end
