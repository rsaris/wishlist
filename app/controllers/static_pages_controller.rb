class StaticPagesController < ApplicationController
  def root
    if signed_in?
      redirect_to user_path( current_user )
    else
      render 'home'
    end
  end

  def home
  end
end
