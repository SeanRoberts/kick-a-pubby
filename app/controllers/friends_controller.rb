class FriendsController < ApplicationController
  before_filter :not_a_pubby_required

  def new
    @friend = Friend.new
  end

  def edit
    @friend = current_user.friend(params[:id])
  end

  def update
    @friend = current_user.friend(params[:id])
    if @friend.update_attributes(params[:friend])
      flash[:notice] = "Friend updated!"
      redirect_to friends_path
    else
      render action: :edit
    end
  end

  def create
    @friend = current_user.add_friend(params[:friend])
    if @friend.valid?
      flash[:notice] = "Welcome to the friend zone!"
      redirect_to friends_path
    else
      render action: :new
    end
  end

  def destroy
    @friend = current_user.friend(params[:id])
    @friend.destroy
    flash[:notice] = "Sorry it didn't work out with #{@friend.name}."
    redirect_to friends_path
  end
end