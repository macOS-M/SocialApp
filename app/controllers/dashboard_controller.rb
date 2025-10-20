class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @post = current_user.posts.new
    @posts = Post.order(created_at: :desc).limit(10)
    @friends = @user.friends.limit(5) if @user.respond_to?(:friends)
  end
end
