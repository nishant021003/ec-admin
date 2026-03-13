# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin users", type: :request do
  let!(:admin) { sign_in_admin }

  describe "GET /admin/users" do
    it "lists users" do
      create_list(:user, 2).each { |u| u.add_role :admin }
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/users" do
    it "creates an admin user" do
      expect {
        post admin_users_path, params: {
          user: { name: "New Admin", email: "admin2@example.com", password: "Password123!", password_confirmation: "Password123!" }
        }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(admin_users_path)
      expect(User.last.has_role?(:admin)).to be true
    end
  end

  describe "PATCH /admin/users/:id" do
    it "updates a user" do
      user = create(:user).tap { |u| u.add_role :admin }
      patch admin_user_path(user), params: { user: { name: "Updated Name", email: user.email } }
      expect(user.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes another user" do
      other = create(:user).tap { |u| u.add_role :admin }
      expect { delete admin_user_path(other) }.to change(User, :count).by(-1)
    end

    it "cannot delete self" do
      expect { delete admin_user_path(admin) }.not_to change(User, :count)
      expect(response).to redirect_to(admin_users_path)
    end
  end
end
