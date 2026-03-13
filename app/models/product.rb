# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :order_line_items, dependent: :restrict_with_exception
  has_many :coupon_products, dependent: :destroy
  has_many :product_combo_triggers, dependent: :destroy
  has_many :product_combo_free_products, dependent: :destroy

  has_many_attached :images

  has_paper_trail

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }

  scope :low_stock, ->(threshold = 5) { where("stock_quantity <= ?", threshold) }
  scope :search, ->(q) { q.present? ? where("name ILIKE ? OR description ILIKE ?", "%#{q}%", "%#{q}%") : all }
  scope :by_status, ->(s) { s.present? ? where(status: s) : all }
  scope :by_category, ->(cat_id) { cat_id.present? ? joins(:categories).where(categories: { id: cat_id }).distinct : all }
  scope :price_between, ->(min, max) {
    scope = all
    scope = scope.where("price >= ?", min) if min.present? && min.to_i.positive?
    scope = scope.where("price <= ?", max) if max.present? && max.to_i.positive?
    scope
  }

  private

  def generate_slug
    base = name.parameterize
    candidate = base
    n = 2
    while Product.where("LOWER(slug) = ?", candidate.downcase).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
