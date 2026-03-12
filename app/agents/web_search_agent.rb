class WebSearchAgent < RubyLLM::Agent
  chat_model Chat
  model "gpt-5-search-api"
end
