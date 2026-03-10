# frozen_string_literal: true

class LocalesController < ApplicationController
  skip_before_action :authenticate_admin!, raise: false

  def switch
    if I18n.available_locales.include?(params[:locale]&.to_sym)
      session[:locale] = params[:locale].to_sym
    end
    redirect_back fallback_location: root_path
  end
end
