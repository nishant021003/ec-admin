# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin gift cards", type: :request do
  before { sign_in_admin }

  describe "GET /admin/gift_cards" do
    it "lists gift cards" do
      create_list(:gift_card, 2)
      get admin_gift_cards_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/gift_cards" do
    it "renders new with errors when invalid" do
      post admin_gift_cards_path, params: { gift_card: { code: "", initial_balance: -1 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a gift card" do
      expect do
        post admin_gift_cards_path, params: {
          gift_card: { code: "GIFT12345", initial_balance: 5000, status: "active" }
        }
      end.to change(GiftCard, :count).by(1)
      expect(response).to redirect_to(admin_gift_card_path(GiftCard.last))
    end
  end

  describe "PATCH /admin/gift_cards/:id" do
    it "updates a gift card" do
      gc = create(:gift_card, status: "active")
      patch admin_gift_card_path(gc), params: {
        gift_card: { code: gc.code, initial_balance: gc.initial_balance, status: "expired" }
      }
      expect(gc.reload.status).to eq("expired")
    end
  end

  describe "DELETE /admin/gift_cards/:id" do
    it "deletes a gift card" do
      gc = create(:gift_card)
      expect { delete admin_gift_card_path(gc) }.to change(GiftCard, :count).by(-1)
    end
  end
end
