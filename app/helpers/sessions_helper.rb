module SessionsHelper
  def current_user
    @current_user ||= User.find_by_oauth_token(cookies[:oauth_token]) if cookies[:oauth_token]
  end
end
