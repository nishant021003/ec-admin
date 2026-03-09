# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  has_secure_password
  has_paper_trail

  has_many :orders, dependent: :nullify
  has_many :coupon_usages, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
