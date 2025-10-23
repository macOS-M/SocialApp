import consumer from "./consumer"

const messagesChannel = consumer.subscriptions.create("MessagesChannel", {

  received(data) {
    const chatWidget = document.querySelector('[data-controller~="chat-widget"]')
    if (chatWidget) {
      const controller = this.application.getControllerForElementAndIdentifier(chatWidget, 'chat-widget')
      if (controller) {
        controller.receiveMessage(data)
      }
    }
    
    const messagesContainer = document.querySelector('.messages-container')
    if (messagesContainer && data.html) {
      messagesContainer.insertAdjacentHTML('beforeend', data.html)
      messagesContainer.scrollTop = messagesContainer.scrollHeight
    }
  }
})

export default messagesChannel
