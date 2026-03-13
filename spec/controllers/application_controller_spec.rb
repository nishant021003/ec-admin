# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    before_action :authenticate_customer!
    def index
      render plain: "OK"
    end
  end

  describe "#authenticate_customer!" do
    it "redirects to customer login when not signed in" do
      get :index
      expect(response).to redirect_to(customer_login_path)
      expect(flash[:alert]).to eq("Please sign in.")
    end

    it "allows access when customer is signed in" do
      customer = create(:customer)
      session[:customer_id] = customer.id
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
