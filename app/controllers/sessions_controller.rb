class SessionsController < ApplicationController
  respond_to :json

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      cookies.permanent[:oauth_token] = user.oauth_token
      render json: {user: user, authorized: true }
    else
      cookies.delete(:oauth_token) if cookies[:oauth_token].present?
      render json: { authorized: false }
    end
  end

  def show
    @user = User.find_all_by_oauth_token(params[:id])
    respond_with @user
  end

  def destroy
    cookies.delete(:oauth_token)
    render json: { authorized: false }
  end
end
