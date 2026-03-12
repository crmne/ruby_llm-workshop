class ChatResponseJob < ApplicationJob
  def perform(chat_id, content)
    agent = TaskPilotAgent.find(chat_id)

    agent.ask(content) do |chunk|
      if chunk.content && !chunk.content.empty?
        message = agent.messages.last
        message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
