# frozen_string_literal: true

class Customer < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
