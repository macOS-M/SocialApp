import consumer from "./consumer"

const messagesChannel = consumer.subscriptions.create("MessagesChannel", {

  received(data) {
    const chatWidget = document.querySelector('[data-controller~="chat-widget"]')
    if (chatWidget) {
      let controller = window.chatWidgetController;
      if (!controller && window.Stimulus && typeof window.Stimulus.getControllerForElementAndIdentifier === 'function') {
        controller = window.Stimulus.getControllerForElementAndIdentifier(chatWidget, 'chat-widget');
      }

      if (controller && typeof controller.receiveMessage === 'function') {
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
