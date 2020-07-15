class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(:username, :password)
    @user = User.create(user_params)
    session[:user_id] = @user.id

    redirect_to '/'
  end
end
