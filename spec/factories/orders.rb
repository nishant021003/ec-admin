# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :customer
    status { "pending" }
    total_cents { 0 }
  end
end
