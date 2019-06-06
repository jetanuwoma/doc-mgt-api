

module V1
  class UsersController < ApplicationController
    skip_before_action :authorize_request, only: :create
    before_action :set_user, only: %i[show update destroy]

    def index
      require_admin
      users = User.all.page(params[:page]).per(params[:per_page] || 5)
      json_response(object: users, show_children: false)
    end

    def create
      verify_password_matches_password_confirmation
      user = User.create!(user_create_params)
      auth_token = Auth::AuthenticateUser.new(user.email, user.password).call
      json_response_auth(
        status: :created,
        object: auth_token,
        message: Message.account_created
      )
    end

    def show
      json_response(object: @user)
    end

    def update
      can_update_user(@user, user_update_params)
      @user.update(user_update_params)
      json_response(
        status: :ok,
        object: @user,
        message: Message.account_updated
      )
    end

    def destroy
      unathorize_current_user_error(@user)
      @user.destroy!
      json_response_default(status: :ok, message: Message.user_deleted)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_create_params
      params.permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation
      )
    end

    def user_update_params
      params.permit(:first_name, :last_name, :role)
    end

    def verify_password_matches_password_confirmation
      password = user_create_params[:password]
      password_confirmation = user_create_params[:password_confirmation]
      return true if password == password_confirmation

      raise ExceptionHandler::PasswordMismatch, Message.password_mismatch
    end
  end
end
