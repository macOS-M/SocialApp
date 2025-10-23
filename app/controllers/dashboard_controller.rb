class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @post = current_user.posts.new
    @posts = Post.order(created_at: :desc).limit(10)
    if @user.respond_to?(:friends)
      @friends = @user.friends.limit(5)
      friend_ids = @friends.map(&:id)
      if friend_ids.any?
        messages = Message.where("(sender_id IN (?) AND recipient_id = ?) OR (sender_id = ? AND recipient_id IN (?))",
                                  friend_ids, current_user.id, current_user.id, friend_ids)
                          .order(created_at: :desc)

        @last_messages = {}
        messages.each do |m|
          partner_id = (m.sender_id == current_user.id) ? m.recipient_id : m.sender_id
          @last_messages[partner_id] ||= m
        end
        unread_counts = Message.where(recipient_id: current_user.id, sender_id: friend_ids, read: false)
                               .group(:sender_id).count
        @unread_counts = Hash[unread_counts.map { |k, v| [ k.to_i, v.to_i ] }]
      else
        @last_messages = {}
        @unread_counts = {}
      end
    end
    @users = User.where.not(id: current_user.id)
  end
end
