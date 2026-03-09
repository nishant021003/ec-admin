# frozen_string_literal: true

module Admin
  class GiftCardsController < Admin::BaseController
    before_action :set_gift_card, only: %i[show edit update destroy]

    def index
      @gift_cards = GiftCard.order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
    end

    def new
      @gift_card = GiftCard.new
    end

    def create
      @gift_card = GiftCard.new(gift_card_params)
      @gift_card.balance = @gift_card.initial_balance if @gift_card.balance.blank?
      if @gift_card.save
        redirect_to admin_gift_card_path(@gift_card), notice: "Gift card was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @gift_card.update(gift_card_params)
        redirect_to admin_gift_card_path(@gift_card), notice: "Gift card was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @gift_card.destroy
      redirect_to admin_gift_cards_path, notice: "Gift card was successfully deleted."
    end

    private

    def set_gift_card
      @gift_card = GiftCard.find(params[:id])
    end

    def gift_card_params
      params.require(:gift_card).permit(:code, :initial_balance, :balance, :status, :expiry_date)
    end
  end
end
