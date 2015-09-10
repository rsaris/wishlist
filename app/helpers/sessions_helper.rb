module SessionsHelper

  def sign_in(user)
    cookies.permanent[:remember_token] = RememberToken.build_remember_token( user )
    cookies.permanent[:user_id] = user.id
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user?(user)
    user == current_user
  end

  def current_user
    @current_user ||= RememberToken.find_user(cookies[:user_id], cookies[:remember_token])
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    if signed_in?
      token = RememberToken.find_token( cookies[:user_id], cookies[:remember_token] )
      if !token.nil?
        token.destroy
      end
    end
    cookies.delete(:remember_token)
    cookies.delete(:user_id)
    self.current_user = nil
  end

  ###### ACTION METHODS #######
  def signed_in_user
    unless signed_in?
      flash[:notice] = "Please sign in."
      redirect_to signin_url
    end
  end

  def already_signed_in
    if signed_in?
      flash[:notice] = "You are already signed in!"
      redirect_to root_path
    end
  end

  def correct_user
    if signed_in?
      @user = User.find(params[:id])
      redirect_to(user_path(@current_user)) unless current_user?(@user)
    else
      flash[:notice] = "Please sign in."
      redirect_to signin_url
    end
  end

end
