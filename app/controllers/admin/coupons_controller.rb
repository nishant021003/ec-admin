# frozen_string_literal: true

module Admin
  class CouponsController < Admin::BaseController
    before_action :set_coupon, only: %i[show edit update destroy]

    def index
      @coupons = Coupon.order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
    end

    def new
      @coupon = Coupon.new
    end

    def create
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to admin_coupon_path(@coupon), notice: "Coupon was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupon_path(@coupon), notice: "Coupon was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @coupon.destroy
      redirect_to admin_coupons_path, notice: "Coupon was successfully deleted."
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(
        :code, :discount_type, :discount_value, :max_discount, :min_cart_value,
        :usage_limit, :per_user_limit, :start_date, :expiry_date, :status
      )
    end
  end
end
