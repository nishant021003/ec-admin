# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[edit update destroy]

    def index
      @users = User.includes(:roles).order(:name).page(params[:page]).per(10)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        @user.add_role :admin
        redirect_to admin_users_path, notice: "Admin user was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      update_params = user_params.to_h
      if update_params["password"].blank?
        update_params.delete("password")
        update_params.delete("password_confirmation")
      end
      if @user.update(update_params)
        redirect_to admin_users_path, notice: "Admin user was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.id == current_user.id
        redirect_to admin_users_path, alert: "You cannot delete yourself."
        return
      end
      @user.destroy
      redirect_to admin_users_path, notice: "Admin user was successfully deleted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
end
