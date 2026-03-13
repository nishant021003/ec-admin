# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "requires name" do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it "requires email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "requires unique email" do
    create(:user, email: "test@example.com")
    user = build(:user, email: "test@example.com")
    expect(user).not_to be_valid
  end

  it "can have roles" do
    user = create(:user)
    user.add_role :admin
    expect(user.has_role?(:admin)).to be true
  end

  it "normalizes email to lowercase" do
    user = create(:user, email: "TEST@Example.COM")
    expect(user.email).to eq("test@example.com")
  end
end
