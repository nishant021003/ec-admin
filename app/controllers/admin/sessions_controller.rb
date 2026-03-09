# frozen_string_literal: true

module Admin
  class SessionsController < ApplicationController
    layout "admin_session"

    def new
      redirect_to admin_root_path if current_user
    end

    def create
      user = User.find_by("LOWER(email) = ?", params[:email]&.downcase&.strip)
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to admin_root_path, notice: "Signed in successfully."
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:user_id)
      redirect_to admin_login_path, notice: "Signed out."
    end
  end
end
