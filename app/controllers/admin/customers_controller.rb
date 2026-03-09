# frozen_string_literal: true

module Admin
  class CustomersController < Admin::BaseController
    before_action :set_customer, only: %i[show edit update destroy]

    def index
      @customers = Customer.all
      @customers = @customers.where("name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @customers = @customers.order(:name).page(params[:page]).per(10)
    end

    def show
    end

    def new
      @customer = Customer.new
    end

    def create
      @customer = Customer.new(customer_params)
      if @customer.save
        redirect_to admin_customer_path(@customer), notice: "Customer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "Customer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @customer.destroy
      redirect_to admin_customers_path, notice: "Customer was successfully deleted."
    end

    private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      attrs = %i[name email]
      attrs += %i[password password_confirmation] if params.dig(:customer, :password).present?
      params.require(:customer).permit(attrs)
    end
  end
end
