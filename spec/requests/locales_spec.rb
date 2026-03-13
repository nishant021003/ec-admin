# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locales", type: :request do
  describe "GET /locale/:locale" do
    it "switches locale when valid" do
      get switch_locale_path("ja")
      expect(response).to have_http_status(:redirect)
      expect(session[:locale]).to eq(:ja)
    end

    it "redirects when invalid locale" do
      get switch_locale_path("invalid")
      expect(response).to have_http_status(:redirect)
      expect(session[:locale]).to be_nil
    end
  end
end
