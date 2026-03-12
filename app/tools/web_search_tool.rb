class WebSearchTool < RubyLLM::Tool
  description "Searches the web for current information. Use this when the user " \
              "needs up-to-date facts, recent news, documentation, or anything " \
              "that requires real-time web access."

  param :query, desc: "The search query"

  def execute(query:)
    WebSearchAgent.create.ask(query).content
  end
end
