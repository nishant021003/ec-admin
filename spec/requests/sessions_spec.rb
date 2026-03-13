# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Customer sessions (SessionsController)", type: :request do
  describe "GET /login (customer)" do
    it "renders the login form" do
      get customer_login_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to root when customer already signed in" do
      customer = create(:customer)
      post customer_login_path, params: { email: customer.email, password: "Password123!" }
      get customer_login_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /login (customer)" do
    it "signs in with valid credentials" do
      customer = create(:customer)
      post customer_login_path, params: { email: customer.email, password: "Password123!" }
      expect(response).to redirect_to(root_path)
      expect(session[:customer_id]).to eq(customer.id)
      expect(flash[:notice]).to eq("Signed in successfully.")
    end

    it "fails with invalid credentials" do
      customer = create(:customer)
      post customer_login_path, params: { email: customer.email, password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:customer_id]).to be_nil
      expect(flash[:alert]).to eq("Invalid email or password.")
    end

    it "fails when customer not found" do
      post customer_login_path, params: { email: "nonexistent@example.com", password: "Password123!" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:customer_id]).to be_nil
    end
  end

  describe "DELETE /logout (customer)" do
    it "signs out the customer" do
      customer = create(:customer)
      post customer_login_path, params: { email: customer.email, password: "Password123!" }
      delete customer_logout_path
      expect(session[:customer_id]).to be_nil
      expect(response).to redirect_to(customer_login_path)
      expect(flash[:notice]).to eq("Signed out.")
    end
  end
end
