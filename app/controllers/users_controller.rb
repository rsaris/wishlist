class UsersController < ApplicationController

  before_action :signed_in_user, except: [:new, :create, :update, :mark_gift_request_purchased, :delete_gift_request]
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

  def buy_gift
    user = User.find( params[:user_id] )
    buyer = User.find( params[:buyer_user_id] )

    if buyer.has_friend?( user )
      Gift.create(
        :user_id => user.id,
        :buyer_user_id => buyer.id,
        :name => params[:gift][:name],
        :description => params[:gift][:description]
      )
    end

    flash[:success] = 'Gift purchase logged.'

    redirect_to user_path( user )
  end

  def mark_gift_request_purchased
    gift_request = GiftRequest.find( params[:gift_request_id] )
    if !current_user.has_friend_with_id?( gift_request.user_id )
      flash[:error] = 'Can not purchase gift for non-friend'
    elsif gift_request.purchased?
      flash[:error] = 'This gift has already been marked as purchased'
    else
      gift_request.update_attribute( :purchased_by_user_id, current_user.id )
      if params[:copy_item] == 'true'
        Gift.create(
          :user_id => gift_request.user_id,
          :buyer_user_id => current_user.id,
          :name => gift_request.name,
          :description => gift_request.description
        )
      end
      flash[:success] = 'Gift marked as purchased'
    end

    redirect_to user_path( gift_request.user_id )
  end

  def delete_gift_request
    gift_request = GiftRequest.find( params[:gift_request_id] )

    if current_user_id?( gift_request.user_id )
      gift_request.destroy
      flash[:success] = 'Gift request destroyed.'
    else
      flash[:error] = 'Can not delete gift requests for other users'
    end

    redirect_to user_path( gift_request.user_id )
  end

  private
  def user_params
    params.require( :user ).permit( :full_name, :email, :password, :password_confirmation )
  end
end
