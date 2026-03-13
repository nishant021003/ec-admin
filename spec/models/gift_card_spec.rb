# frozen_string_literal: true

require "rails_helper"

RSpec.describe GiftCard, type: :model do
  it "is valid with valid attributes" do
    gc = build(:gift_card)
    expect(gc).to be_valid
  end

  it "requires code" do
    gc = build(:gift_card, code: nil)
    expect(gc).not_to be_valid
  end

  it "validates status inclusion" do
    gc = build(:gift_card, status: "invalid")
    expect(gc).not_to be_valid
  end

  it "requires unique code" do
    create(:gift_card, code: "GIFT123")
    gc = build(:gift_card, code: "GIFT123")
    expect(gc).not_to be_valid
  end

  it "sets balance from initial_balance on create" do
    gc = create(:gift_card, initial_balance: 5000)
    expect(gc.balance).to eq(5000)
  end

  describe "#redeemable?" do
    it "returns true when active and has balance" do
      gc = create(:gift_card, status: "active", initial_balance: 1000)
      expect(gc.redeemable?).to be true
    end

    it "returns false when status is redeemed" do
      gc = create(:gift_card, status: "redeemed", initial_balance: 100)
      expect(gc.redeemable?).to be false
    end

    it "returns false when balance is zero" do
      gc = create(:gift_card, status: "active", initial_balance: 0)
      expect(gc.redeemable?).to be false
    end

    it "returns false when expired" do
      gc = create(:gift_card, status: "active", initial_balance: 100, expiry_date: 1.day.ago)
      expect(gc.redeemable?).to be false
    end
  end

  describe "#apply_amount" do
    it "returns min of amount and balance" do
      gc = create(:gift_card, initial_balance: 500)
      expect(gc.apply_amount(300)).to eq(300)
      expect(gc.apply_amount(700)).to eq(500)
    end

    it "returns 0 when not redeemable" do
      gc = create(:gift_card, status: "redeemed", initial_balance: 100)
      expect(gc.apply_amount(50)).to eq(0)
    end
  end

  describe "#deduct!" do
    it "reduces balance and creates transaction" do
      gc = create(:gift_card, initial_balance: 1000)
      order = create(:order)
      result = gc.deduct!(300, order: order)
      expect(result).to be true
      expect(gc.reload.balance).to eq(700)
      expect(gc.gift_card_transactions.count).to eq(1)
      txn = gc.gift_card_transactions.last
      expect(txn.amount).to eq(300)
      expect(txn.transaction_type).to eq("debit")
    end

    it "sets status to redeemed when balance reaches zero" do
      gc = create(:gift_card, initial_balance: 300)
      gc.deduct!(300)
      expect(gc.reload.status).to eq("redeemed")
      expect(gc.balance).to eq(0)
    end

    it "returns false when not redeemable" do
      gc = create(:gift_card, status: "redeemed", initial_balance: 0)
      expect(gc.deduct!(100)).to be false
    end
  end
end
