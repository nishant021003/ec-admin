# frozen_string_literal: true

module Admin
  class ProductsController < Admin::BaseController
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @products = Product
        .search(params[:q])
        .by_status(params[:status])
        .by_category(params[:category_id])
        .price_between(params[:min_price], params[:max_price])
        .order(created_at: :desc)
        .page(params[:page])
        .per(10)
    end

    def show
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_product_path(@product), notice: "Product was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Product was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy!
      redirect_to admin_products_path, notice: "Product was successfully deleted."
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_product_path(@product), alert: "Cannot delete product: it has been used in orders."
    end

    def export
      products = Product.includes(:categories).order(:name)
      csv = generate_products_csv(products)
      send_data csv, filename: "products_#{Time.current.strftime('%Y%m%d_%H%M')}.csv", type: "text/csv"
    end

    def import
      unless params[:file].present?
        redirect_to admin_products_path, alert: "Please select a CSV file."
        return
      end
      result = ProductImportService.new(params[:file].path).call
      if result[:errors].empty?
        redirect_to admin_products_path, notice: "Imported #{result[:imported]} products."
      else
        redirect_to admin_products_path, alert: "Imported #{result[:imported]}. Errors: #{result[:errors].join(', ')}"
      end
    end

    def bulk_action
      ids = (params[:product_ids] || []).reject(&:blank?)
      if ids.empty?
        redirect_to admin_products_path, alert: "Select at least one product."
        return
      end
      case params[:bulk_action]
      when "update"
        if params[:bulk_status].present?
          Product.where(id: ids).update_all(status: params[:bulk_status])
          redirect_to admin_products_path, notice: "Updated #{ids.size} product(s)."
        else
          redirect_to admin_products_path, alert: "Select a status to update."
        end
      when "destroy"
        deleted = 0
        skipped = []
        Product.where(id: ids).each do |p|
          p.destroy!
          deleted += 1
        rescue ActiveRecord::DeleteRestrictionError
          skipped << p.name
        end
        msg = "Deleted #{deleted} product(s)."
        msg += " Skipped (used in orders): #{skipped.join(', ')}" if skipped.any?
        redirect_to admin_products_path, notice: msg
      else
        redirect_to admin_products_path, alert: "Invalid action."
      end
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :status, :stock_quantity, category_ids: [], images: [])
    end

    def generate_products_csv(products)
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << %w[id name slug description price status stock_quantity categories]
        products.each do |p|
          csv << [p.id, p.name, p.slug, p.description, p.price, p.status, p.stock_quantity, p.categories.pluck(:name).join("; ")]
        end
      end
    end
  end
end
