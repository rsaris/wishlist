class UsersController < ApplicationController

  before_action :correct_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new( user_params )
    if @user.save
      flash[:success] = 'Welcome to WishList'
      sign_in( @user )
      redirect_to user_path( @user )
    else
      render 'new'
    end
  end

  def show
    @user = User.find( params[:id] )
  end

  def search
    @users = User.by_search( params[:search] )
    respond_to do |format|
      format.json
    end
  end

  private
  def user_params
    params.require( :user ).permit( :full_name, :email, :password, :password_confirmation )
  end
end
