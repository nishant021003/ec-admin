# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin sessions", type: :request do
  describe "GET /admin/login" do
    it "renders the login form" do
      get admin_login_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to dashboard when already signed in" do
      user = create(:user)
      user.add_role :admin
      post admin_login_path, params: { email: user.email, password: "Password123!" }
      get admin_login_path
      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "POST /admin/login" do
    it "signs in with valid credentials" do
      user = create(:user)
      user.add_role :admin
      post admin_login_path, params: { email: user.email, password: "Password123!" }
      expect(response).to redirect_to(admin_root_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it "fails with invalid credentials" do
      user = create(:user)
      post admin_login_path, params: { email: user.email, password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:user_id]).to be_nil
    end
  end
end
