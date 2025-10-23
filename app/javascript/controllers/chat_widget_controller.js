import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messagesContainer", "messageInput", "messageForm", "recipientId", "sendButton"]
  static values = {
    userId: Number,
    username: String,
    currentUserId: Number
  }

  connect() {
    console.log("Chat widget controller connected")
    this.isMinimized = true
    this.currentRecipientId = null
    this.setupActionCable()
    
    window.chatWidgetController = this
  }

  setupActionCable() {
    if (window.messagesChannel) {
      console.log("ActionCable already set up")
    }
  }

  async openChat(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const userId = event.currentTarget.dataset.chatWidgetUserIdValue
    const username = event.currentTarget.dataset.chatWidgetUsernameValue
    
    this.currentRecipientId = userId
    this.recipientIdTarget.value = userId
    
    // Update header
    document.getElementById('chat-recipient-name').textContent = username
    const avatarImg = document.getElementById('chat-recipient-avatar-img')
    const avatarInitial = document.getElementById('chat-recipient-avatar')
    const avatarUrl = event.currentTarget.dataset.avatar || ''
    if (avatarUrl && avatarUrl.length > 0) {
      avatarImg.src = avatarUrl
      avatarImg.classList.remove('hidden')
      avatarInitial.classList.add('hidden')
    } else {
      avatarImg.src = ''
      avatarImg.classList.add('hidden')
      avatarInitial.classList.remove('hidden')
      avatarInitial.textContent = username.charAt(0).toUpperCase()
    }
    
    // Show and expand widget
    const widget = document.getElementById('chat-widget')
    widget.classList.remove('hidden')
    this.isMinimized = false
    document.getElementById('chat-body').style.height = 'auto'
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.innerHTML = '<p class="text-center text-gray-500 text-sm">Loading messages...</p>'
    } else {
      const container = document.getElementById('chat-messages')
      if (container) container.innerHTML = '<p class="text-center text-gray-500 text-sm">Loading messages...</p>'
    }

    await this.loadMessages(userId)

    if (this.messageInputTarget) this.messageInputTarget.focus()
  }

  toggleMinimize(event) {
    event.stopPropagation()
    const chatBody = document.getElementById('chat-body')
    const minimizeIcon = document.getElementById('minimize-icon')
    
    if (this.isMinimized) {
      chatBody.style.height = 'auto'
      this.isMinimized = false
      minimizeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>'
    } else {
      chatBody.style.height = '0'
      this.isMinimized = true
      minimizeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"></path>'
    }
  }

  closeChat(event) {
    event.stopPropagation()
    const widget = document.getElementById('chat-widget')
    widget.classList.add('hidden')
    this.currentRecipientId = null
    this.messagesContainerTarget.innerHTML = '<p class="text-center text-gray-500 text-sm">Loading messages...</p>'
  }

  async loadMessages(userId) {
    try {
      const response = await fetch(`/messages/${userId}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.renderMessages(data.messages)
      } else {
        this.messagesContainerTarget.innerHTML = '<p class="text-center text-red-500 text-sm">Failed to load messages</p>'
      }
    } catch (error) {
      console.error('Error loading messages:', error)
      this.messagesContainerTarget.innerHTML = '<p class="text-center text-red-500 text-sm">Error loading messages</p>'
    }
  }

  renderMessages(messages) {
    if (messages.length === 0) {
      this.messagesContainerTarget.innerHTML = '<p class="text-center text-gray-500 text-sm">No messages yet. Start the conversation!</p>'
      return
    }
    
    this.messagesContainerTarget.innerHTML = messages.map(msg => this.messageHTML(msg)).join('')
    this.scrollToBottom()
  }

  messageHTML(message) {
    const isCurrentUser = message.sender_id === this.currentUserIdValue
    const alignment = isCurrentUser ? 'justify-end' : 'justify-start'
    const bgColor = isCurrentUser ? 'bg-indigo-600 text-white' : 'bg-gray-200 text-gray-900'
    const timeColor = isCurrentUser ? 'text-indigo-100' : 'text-gray-500'
    
    return `
      <div class="flex ${alignment}">
        <div class="${bgColor} rounded-lg px-4 py-2 max-w-xs break-words shadow">
          <p class="text-sm">${this.escapeHtml(message.body)}</p>
          <p class="text-xs ${timeColor} mt-1">${this.formatTime(message.created_at)}</p>
        </div>
      </div>
    `
  }

  async sendMessage(event) {
    event.preventDefault()
    
    const body = this.messageInputTarget.value.trim()
    if (!body) return
    
    if (!this.currentRecipientId) {
      alert('Please select a recipient')
      return
    }
    
    this.sendButtonTarget.disabled = true
    
    try {
      const formData = new FormData()
      formData.append('message[recipient_id]', this.currentRecipientId)
      formData.append('message[body]', body)
      
      const response = await fetch('/messages', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: formData
      })
      
      if (response.ok) {
        const data = await response.json()
        this.messageInputTarget.value = ''
        
        const messageHTML = this.messageHTML(data.message)
        this.messagesContainerTarget.insertAdjacentHTML('beforeend', messageHTML)
        this.scrollToBottom()
      } else {
        alert('Failed to send message')
      }
    } catch (error) {
      console.error('Error sending message:', error)
      alert('Error sending message')
    } finally {
      this.sendButtonTarget.disabled = false
      this.messageInputTarget.focus()
    }
  }

  scrollToBottom() {
    this.messagesContainerTarget.scrollTop = this.messagesContainerTarget.scrollHeight
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  formatTime(timestamp) {
    const date = new Date(timestamp)
      return date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      })
  }

  receiveMessage(data) {
    if (this.currentRecipientId == data.sender_id || this.currentRecipientId == data.recipient_id) {
      this.loadMessages(this.currentRecipientId)
    }
  }
}
