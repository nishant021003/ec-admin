# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin customers", type: :request do
  before { sign_in_admin }

  describe "GET /admin/customers" do
    it "lists customers" do
      create_list(:customer, 2)
      get admin_customers_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/customers" do
    it "renders new with errors when invalid" do
      post admin_customers_path, params: { customer: { name: "", email: "bad" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a customer" do
      expect do
        post admin_customers_path, params: {
          customer: { name: "New Customer", email: "new@example.com", password: "Secret123!", password_confirmation: "Secret123!" }
        }
      end.to change(Customer, :count).by(1)
      expect(response).to redirect_to(admin_customer_path(Customer.last))
    end
  end

  describe "PATCH /admin/customers/:id" do
    it "updates a customer" do
      customer = create(:customer, name: "Old Name")
      patch admin_customer_path(customer), params: { customer: { name: "New Name", email: customer.email } }
      expect(customer.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /admin/customers/:id" do
    it "deletes a customer" do
      customer = create(:customer)
      expect { delete admin_customer_path(customer) }.to change(Customer, :count).by(-1)
    end
  end
end
