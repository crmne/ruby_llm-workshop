class SequentialPipelineJob < ApplicationJob
  def perform(chat_id, content)
    agent = TaskPilotAgent.find(chat_id)

    # Stage 1: Research (creates its own visible chat)
    research = WebSearchAgent.create.ask(content).content

    # Stage 2: Act on research (uses the user's chat, with streaming)
    prompt = <<~PROMPT
      Based on this research:

      #{research}

      Now help the user with: #{content}
    PROMPT

    agent.ask(prompt) do |chunk|
      if chunk.content && !chunk.content.empty?
        message = agent.messages.last
        message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
