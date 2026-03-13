# frozen_string_literal: true

module Admin
  class ProductCombosController < Admin::BaseController
    before_action :set_product_combo, only: %i[show edit update destroy]

    def index
      @product_combos = ProductCombo.includes(
        product_combo_triggers: :product,
        product_combo_free_products: :product
      ).order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
    end

    def new
      @product_combo = ProductCombo.new(is_active: true)
    end

    def create
      ProductCombo.reset_column_information
      pc = params[:product_combo] || {}
      attrs = {
        "is_active" => pc["is_active"] != "false",
        "valid_from" => pc["valid_from"].presence,
        "valid_to" => pc["valid_to"].presence
      }
      @product_combo = ProductCombo.new(attrs)
      build_combo_products_from_params(@product_combo)
      if @product_combo.save
        redirect_to admin_product_combo_path(@product_combo), notice: "Product combo was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      base = product_combo_base_params.to_h.slice("is_active", "valid_from", "valid_to")
      if @product_combo.update(base)
        @product_combo.product_combo_triggers.destroy_all
        @product_combo.product_combo_free_products.destroy_all
        build_combo_products_for_update(@product_combo)
        redirect_to admin_product_combo_path(@product_combo), notice: "Product combo was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product_combo.destroy
      redirect_to admin_product_combos_path, notice: "Product combo was successfully deleted."
    end

    private

    def set_product_combo
      @product_combo = ProductCombo.includes(product_combo_triggers: :product, product_combo_free_products: :product).find(params[:id])
    end

    def product_combo_base_params
      params.require(:product_combo).permit(:is_active, :valid_from, :valid_to)
    end

    def build_combo_products_from_params(combo)
      pc_params = params[:product_combo] || {}
      trigger_ids = Array(pc_params[:trigger_product_ids]).reject(&:blank?).map(&:to_i).uniq
      free_ids = Array(pc_params[:free_product_ids]).reject(&:blank?).map(&:to_i).uniq
      trigger_qty = [pc_params[:trigger_quantity].to_i, 1].max
      free_qty = [pc_params[:free_quantity].to_i, 1].max

      trigger_ids.each { |pid| combo.product_combo_triggers.build(product_id: pid, quantity: trigger_qty) }
      free_ids.each { |pid| combo.product_combo_free_products.build(product_id: pid, quantity: free_qty) }
    end

    def build_combo_products_for_update(combo)
      pc_params = params[:product_combo] || {}
      trigger_ids = Array(pc_params[:trigger_product_ids]).reject(&:blank?).map(&:to_i).uniq
      free_ids = Array(pc_params[:free_product_ids]).reject(&:blank?).map(&:to_i).uniq
      trigger_qty = [pc_params[:trigger_quantity].to_i, 1].max
      free_qty = [pc_params[:free_quantity].to_i, 1].max

      trigger_ids.each { |pid| combo.product_combo_triggers.create!(product_id: pid, quantity: trigger_qty) }
      free_ids.each { |pid| combo.product_combo_free_products.create!(product_id: pid, quantity: free_qty) }
    end
  end
end
