class ApplicationController < ActionController::Base
  include Localization

  before_action :authorized
  helper_method :current_user
  helper_method :logged_in?

  def authorized
    redirect_to '/welcome' unless logged_in?
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user
    User.find_by(id: session[:user_id])
  end
end
