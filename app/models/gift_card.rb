# frozen_string_literal: true

class GiftCard < ApplicationRecord
  STATUSES = %w[active redeemed expired].freeze

  has_many :gift_card_transactions, dependent: :destroy

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :initial_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :normalize_code
  before_validation :set_balance_from_initial, on: :create

  scope :active, -> { where(status: "active") }

  def redeemable?
    active? && balance.positive? && !expired?
  end

  def active?
    status == "active"
  end

  def expired?
    expiry_date.present? && Date.current > expiry_date
  end

  def apply_amount(amount_cents)
    return 0 unless redeemable?
    [amount_cents, balance].min
  end

  def deduct!(amount_cents, order: nil)
    return false unless redeemable?
    amount = [amount_cents, balance].min
    return false if amount <= 0

    new_balance = balance - amount
    new_status = new_balance.zero? ? "redeemed" : "active"

    transaction do
      update!(balance: new_balance, status: new_status)
      gift_card_transactions.create!(
        order: order,
        amount: amount,
        transaction_type: "debit"
      )
      true
    end
  end

  private

  def set_balance_from_initial
    self.balance = initial_balance if new_record? && initial_balance.present?
  end

  def normalize_code
    self.code = code.to_s.upcase.strip.gsub(/\s+/, "") if code.present?
  end
end
