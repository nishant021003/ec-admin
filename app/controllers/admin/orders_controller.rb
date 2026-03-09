# frozen_string_literal: true

module Admin
  class OrdersController < Admin::BaseController
    before_action :set_order, only: %i[show update]

    def index
      @orders = Order.includes(:customer, :order_line_items)
      @orders = @orders.where(status: params[:status]) if params[:status].present?
      @orders = @orders.order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
    end

    def update
      status = params.require(:order).permit(:status)[:status]
      if Order::STATUSES.include?(status)
        @order.update!(status: status)
        redirect_to admin_order_path(@order), notice: "Order status updated."
      else
        redirect_to admin_order_path(@order), alert: "Invalid status."
      end
    end

    def export
      orders = Order.includes(:customer, :order_line_items => :product).order(created_at: :desc)
      csv = generate_orders_csv(orders)
      send_data csv, filename: "orders_#{Time.current.strftime('%Y%m%d_%H%M')}.csv", type: "text/csv"
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def generate_orders_csv(orders)
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << %w[id customer_name customer_email status final_amount created_at]
        orders.each do |o|
          csv << [o.id, o.customer&.name, o.customer&.email, o.status, o.final_amount, o.created_at]
        end
      end
    end
  end
end
