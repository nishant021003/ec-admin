# frozen_string_literal: true

module ApplicationHelper
  def translate_status(status)
    return status if status.blank?
    t("status.#{status}", default: status.to_s.titleize)
  end
end
