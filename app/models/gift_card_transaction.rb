# frozen_string_literal: true

class GiftCardTransaction < ApplicationRecord
  TRANSACTION_TYPES = %w[debit credit].freeze

  belongs_to :gift_card
  belongs_to :order, optional: true

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }
end
