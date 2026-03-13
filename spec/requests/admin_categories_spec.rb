# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin categories", type: :request do
  before { sign_in_admin }

  describe "GET /admin/categories" do
    it "lists categories" do
      create_list(:category, 3)
      get admin_categories_path
      expect(response).to have_http_status(:ok)
    end

    it "shows category details" do
      category = create(:category, name: "Electronics")
      get admin_category_path(category)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Electronics")
    end
  end

  describe "POST /admin/categories" do
    it "renders new with errors when invalid" do
      post admin_categories_path, params: { category: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a category" do
      expect {
        post admin_categories_path, params: { category: { name: "Electronics" } }
      }.to change(Category, :count).by(1)
      expect(response).to redirect_to(admin_category_path(Category.last))
    end
  end

  describe "GET /admin/categories/:id (show)" do
    it "displays category with parent" do
      parent = create(:category, name: "Parent")
      child = create(:category, name: "Child", parent: parent)
      get admin_category_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/categories/:id" do
    it "renders edit with errors when invalid" do
      category = create(:category)
      patch admin_category_path(category), params: { category: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates a category" do
      category = create(:category, name: "Old Name")
      patch admin_category_path(category), params: { category: { name: "New Name" } }
      expect(category.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /admin/categories/:id" do
    it "deletes a category" do
      category = create(:category)
      expect { delete admin_category_path(category) }.to change(Category, :count).by(-1)
    end
  end
end
