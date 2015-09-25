class UsersController < ApplicationController

  before_action :signed_in_user, except: [:new, :create, :update]
  before_action :correct_user, only: [:update]

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
    if params[:search]
      @users = User.by_search( params[:search] ).where( "id != ?", current_user.id )
    else
      @users = []
    end
  end

  def update
    user = User.find( params[:id] )

    params[:user][:gift_requests_attributes].each do |key, hash|
      hash[:user_id] = user.id
      GiftRequest.create( hash )
    end

    redirect_to user_path( user )
  end

  def search
    @users = User.by_search( params[:search] ).where( "id != ?", current_user.id )
    respond_to do |format|
      format.json
    end
  end

  def add_friend
    @friend = User.find( params[:friend_id] )
    Friendship.create( :friend_id => @friend.id, :user_id => current_user.id )
    flash[:success] = 'Friend added!'
    redirect_to users_path
  end

  def accept_friend
    @request = Friendship.find( params[:friendship_id] )

    if @request.friend_id == current_user.id
      @request.update_attribute( :accepted, true )
      flash[:success] = 'Request accepted.'
    end

    redirect_to user_path( current_user )
  end

  def deny_friend
    @request = Friendship.find( params[:friendship_id] )
    if @request.friend_id == current_user.id
      @request.destroy
      flash[:success] = 'Request deleted.'
    end

    redirect_to user_path( current_user )
  end

  private
  def user_params
    params.require( :user ).permit( :full_name, :email, :password, :password_confirmation )
  end
end
