# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :set_locale
  helper_method :current_user, :current_customer

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_customer
    @current_customer ||= Customer.find_by(id: session[:customer_id]) if session[:customer_id]
  end

  def authenticate_admin!
    redirect_to admin_login_path, alert: t("auth.please_sign_in") unless current_user
  end

  def authenticate_customer!
    redirect_to customer_login_path, alert: "Please sign in." unless current_customer
  end
end
