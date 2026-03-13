# frozen_string_literal: true

module RequestHelper
  def sign_in_admin
    admin = create(:user).tap { |u| u.add_role :admin }
    post admin_login_path, params: { email: admin.email, password: "Password123!" }
    admin
  end
end
