# frozen_string_literal: true

FactoryBot.define do
  factory :gift_card do
    sequence(:code) { |n| "GIFT#{n}#{format('%03d', n % 1000)}" }
    initial_balance { 1000 }
    status { "active" }
  end
end
