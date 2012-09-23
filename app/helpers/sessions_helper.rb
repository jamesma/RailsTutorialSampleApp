# this module is used by Controllers (besides Views)
module SessionsHelper

  # place a remember token as a cookie on the user's browser,
  # and then use the token to find the user record in the db as
  # the user moves from page to page
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token

    # self.current_user ... is automatically converted to current_user=(...)
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    # same as @current_user = @current_user || User.find_by_remember_token(cookies[:remember_token])
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  # friendly forwarding
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  # friendly forwarding
  def store_location
    session[:return_to] = request.url
  end
end
