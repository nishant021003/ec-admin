# frozen_string_literal: true

FactoryBot.define do
  factory :product_combo do
    is_active { true }

    transient do
      trigger_product { nil }
      free_product { nil }
    end

    after(:build) do |combo, evaluator|
      if evaluator.trigger_product && evaluator.free_product
        combo.product_combo_triggers.build(product: evaluator.trigger_product, quantity: 1)
        combo.product_combo_free_products.build(product: evaluator.free_product, quantity: 1)
      end
    end
  end
end
