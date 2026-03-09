# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def index
      @total_orders = Order.count
      @total_products = Product.count
      @total_customers = Customer.count
      @total_categories = Category.count
      @total_coupons = Coupon.count
      @total_gift_cards = GiftCard.count
      @low_stock_count = Product.low_stock.count
      @recent_orders = Order.includes(:customer).order(created_at: :desc).limit(5)
      @orders_by_day_7 = Order.where("created_at >= ?", 7.days.ago).group("created_at::date").count
      @orders_by_day_30 = Order.where("created_at >= ?", 30.days.ago).group("created_at::date").count
    end
  end
end
