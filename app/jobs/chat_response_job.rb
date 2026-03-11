class ChatResponseJob < ApplicationJob
  def perform(chat_id, content)
    chat = Chat.find(chat_id)

    chat.with_instructions(<<~PROMPT)
      You are TaskPilot, an AI task management assistant. You help users
      organize their work and life by managing their todo list.

      Be concise, friendly, and action-oriented. When users describe tasks,
      help them break things down into clear, actionable items.

      Always respond in a helpful, encouraging tone.
    PROMPT

    chat.ask(content) do |chunk|
      if chunk.content && !chunk.content.empty?
        message = chat.messages.last
        message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
