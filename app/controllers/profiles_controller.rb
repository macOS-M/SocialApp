class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find_by(username: params[:username])

    if @user.nil?
      redirect_to dashboard_path, alert: "User not found"
      return
    end

    @posts = @user.posts.order(created_at: :desc).limit(20)
    @is_own_profile = @user == current_user

    if @is_own_profile
      @friendship_status = :self
    elsif current_user.friends.include?(@user)
      @friendship_status = :friends
    elsif current_user.pending_friends.include?(@user)
      @friendship_status = :pending_sent
    elsif current_user.incoming_pending_friends.include?(@user)
      @friendship_status = :pending_received
      @friendship_request = current_user.inverse_friendships.pending.find_by(user_id: @user.id)
    else
      @friendship_status = :none
    end
  end
end
