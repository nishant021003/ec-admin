# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_customer
  end

  def create
    customer = Customer.find_by("LOWER(email) = ?", params[:email]&.downcase&.strip)
    if customer&.authenticate(params[:password])
      session[:customer_id] = customer.id
      redirect_to root_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:customer_id)
    redirect_to customer_login_path, notice: "Signed out."
  end
end
