# frozen_string_literal: true

class ProductImportService
  def initialize(file_path)
    @file_path = file_path
  end

  def call
    imported = 0
    errors = []
    require "csv"
    CSV.foreach(@file_path, headers: true) do |row|
      product = Product.new(
        name: row["name"]&.strip,
        description: row["description"]&.strip,
        price: (row["price"] || 0).to_i,
        status: row["status"]&.strip&.presence || "draft",
        stock_quantity: (row["stock_quantity"] || 0).to_i
      )
      product.slug = row["slug"]&.strip if row["slug"].present?
      if row["categories"].present?
        cat_names = row["categories"].to_s.split(/[,;]/).map(&:strip).reject(&:blank?)
        product.category_ids = Category.where(name: cat_names).pluck(:id)
      end
      if product.save
        imported += 1
      else
        errors << "Row #{row['name']}: #{product.errors.full_messages.join(', ')}"
      end
    end
    { imported: imported, errors: errors }
  end
end
