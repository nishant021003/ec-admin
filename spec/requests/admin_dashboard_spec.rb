# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  before { sign_in_admin }

  describe "GET /admin (root)" do
    it "shows dashboard" do
      create_list(:order, 2)
      create_list(:product, 3)
      create_list(:customer, 2)
      create_list(:category, 2)
      get admin_root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
