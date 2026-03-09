# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }

  private

  def generate_slug
    base = name.parameterize
    candidate = base
    n = 2
    while Category.where("LOWER(slug) = ?", candidate.downcase).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
