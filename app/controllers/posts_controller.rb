class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to dashboard_path, notice: "Post created successfully."
    else
      @user = current_user
      @posts = Post.order(created_at: :desc).limit(10)
      @friends = @user.friends.limit(5) if @user.respond_to?(:friends)
      flash.now[:alert] = @post.errors.full_messages.to_sentence
      render "dashboard/index", status: :unprocessable_entity
    end
  end
  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to dashboard_path, notice: "Post deleted successfully."
  end
  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to dashboard_path, notice: "Post updated successfully."
    else
      flash.now[:alert] = @post.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
