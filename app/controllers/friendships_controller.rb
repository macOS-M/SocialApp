class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    friend = User.find(params[:friend_id])
    current_user.friendships.create(friend: friend, status: "pending")
    redirect_to dashboard_path, notice: "Friend request sent to #{friend.username}"
  end


  def accept
    friendship = Friendship.find(params[:id])
    unless friendship.friend_id == current_user.id
      return redirect_to dashboard_path, alert: "Not authorized"
    end

    Friendship.transaction do
      friendship.update!(status: "accepted")
      Friendship.find_or_create_by!(user_id: current_user.id, friend_id: friendship.user_id) do |f|
        f.status = "accepted"
      end
    end

    redirect_to dashboard_path, notice: "Friend request accepted!"
  end

  def reject
    friendship = Friendship.find(params[:id])
    unless friendship.friend_id == current_user.id
      return redirect_to dashboard_path, alert: "Not authorized"
    end

    friendship.update(status: "rejected")
    redirect_to dashboard_path, notice: "Friend request rejected"
  end

  def destroy
    other_user_id = params[:id]
    Friendship.where(user_id: current_user.id, friend_id: other_user_id).destroy_all
    Friendship.where(user_id: other_user_id, friend_id: current_user.id).destroy_all
    redirect_to dashboard_path, notice: "Friend removed."
  end
end
