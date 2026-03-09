# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
  end
end
