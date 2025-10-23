function initChatWidgetButtons() {
  document.querySelectorAll('.chat-friend-button').forEach(button => {
    button.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      
      const userId = button.dataset.userId;
      const username = button.dataset.username;
      
      console.log('Chat button clicked:', userId, username);
      
      if (!userId || !username) {
        console.error('Missing userId or username');
        return;
      }
      
      const widget = document.getElementById('chat-widget');
      if (!widget) {
        console.error('Chat widget element not found');
        return;
      }
      
      const controller = window.chatWidgetController || window.Stimulus?.getControllerForElementAndIdentifier(widget, 'chat-widget');
      
      if (!controller) {
        console.error('Chat widget controller not found');
        return;
      }
      
      console.log('Opening chat with controller:', controller);
      
      // Create a fake event to pass to openChat
      const fakeEvent = {
        preventDefault: () => {},
        stopPropagation: () => {},
        currentTarget: {
          dataset: {
            chatWidgetUserIdValue: userId,
            chatWidgetUsernameValue: username
          }
        }
      };
      
      controller.openChat(fakeEvent);
    });
  });
}

document.addEventListener('turbo:load', initChatWidgetButtons);

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initChatWidgetButtons);
} else {
  initChatWidgetButtons();
}
