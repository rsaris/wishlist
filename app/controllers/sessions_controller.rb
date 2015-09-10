class SessionsController < ApplicationController

  before_action :already_signed_in, only: [:new]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = 'You have been signed in.'
      redirect_to user_path( user )
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    flash[:success] = 'You have been signed out.'
    redirect_to :root
  end

end
