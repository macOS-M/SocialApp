
class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true

  scope :unread_for, ->(user) { where(recipient: user, read: false) }
  after_create_commit :broadcast_message

  private

  def broadcast_message
    html = ApplicationController.render(
      partial: 'messages/message',
      locals: { message: self, current_user: self.sender }
    )

    message_data = {
      sender_id: self.sender_id,
      recipient_id: self.recipient_id,
      html: html,
      message: {
        id: self.id,
        body: self.body,
        sender_id: self.sender_id,
        recipient_id: self.recipient_id,
        created_at: self.created_at
      }
    }

    ::MessagesChannel.broadcast_to(self.recipient, message_data)

    ::MessagesChannel.broadcast_to(self.sender, message_data)
  end
end
