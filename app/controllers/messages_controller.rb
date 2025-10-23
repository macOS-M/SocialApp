
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = Message.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
      .order(created_at: :desc)

    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @messages = Message.where(
        "(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
        current_user.id, @user.id, @user.id, current_user.id
      ).order(:created_at)
      @message = Message.new
    end
  end

  def show
    @user = User.find(params[:id])
    @messages = Message.where(
      "(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
      current_user.id, @user.id, @user.id, current_user.id
    ).order(:created_at)
    @message = Message.new

    respond_to do |format|
      format.html
      format.json { render json: { messages: @messages.as_json(only: [:id, :sender_id, :recipient_id, :body, :created_at]) } }
    end
  end

  def create
    @message = Message.new(message_params)
    @message.sender_id = current_user.id
    
    respond_to do |format|
      if @message.save
        format.html { redirect_back(fallback_location: dashboard_path, notice: "Message sent!") }
        format.json { render json: { success: true, message: @message }, status: :created }
      else
        format.html { redirect_back(fallback_location: dashboard_path, alert: "Failed to send message.") }
        format.json { render json: { success: false, errors: @message.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:recipient_id, :body)
  end
end
