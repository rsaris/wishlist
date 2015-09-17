class UsersController < ApplicationController

  before_action :signed_in_user, only: [:show, :index, :add_friend]

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

  def index
  end

  def search
    @users = User.search( params[:search] )
    respond_to do |format|
      format.json
    end
  end

  def add_friend
    @friend = User.find( params[:friend_id] )
    Friendship.create( :friend_id => @friend.id, :user_id => current_user.id )
  end

  private
  def user_params
    params.require( :user ).permit( :full_name, :email, :password, :password_confirmation )
  end
end
