# Building AI-Powered Apps with RubyLLM — Handout

> All the code you need for today's workshop. Copy-paste freely — this isn't a typing contest.
> Sections marked **LIVE CODE** are written together with the instructor. Follow along!

---

## Part 1: The Instant Win

### Commands

```bash
rails new task_pilot --css=tailwind
cd task_pilot
```

```bash
bundle add ruby_llm --git "https://github.com/crmne/ruby_llm.git"
```

```bash
bin/rails generate ruby_llm:install
```

```bash
bin/rails db:migrate
```

```bash
bin/rails ruby_llm:load_models
```

### Set your API key

```bash
bin/rails credentials:edit
```

Add `openai_api_key: sk-your-key-here` and save.

### Generate the chat UI

```bash
bin/rails generate ruby_llm:chat_ui
```

```bash
bin/dev
```

Visit [http://localhost:3000/chats](http://localhost:3000/chats)

### Console exploration

```bash
bin/rails console
```

```ruby
# Pure RubyLLM — no database involved
chat = RubyLLM.chat
response = chat.ask("Hi! What's 2 + 2?")
puts response.content

# Follow-up — the AI remembers context
response = chat.ask("What's RubyLLM?")
puts response.content

# With Rails integration — persisted to database
chat = Chat.create!
chat.ask("Hello from the database!")
Chat.last
Message.last
Message.last.content
Message.last.role
```

Type `exit` to leave the console.

> **Checkpoint:** `git checkout part-1-complete`

---

## Part 2: Making It Ours

### `app/jobs/chat_response_job.rb`

```ruby
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
```

### Hide system messages — `app/views/messages/_system.html.erb`

```erb
<% system ||= local_assigns[:message] %>
<!-- system: <%= system.content %> -->
```

> **Checkpoint:** `git checkout part-2-complete`

---

## Part 3: Teaching AI to Act

### Sub-part A: Weather Tool

```bash
bin/rails generate ruby_llm:tool Weather
```

#### `app/tools/weather_tool.rb`

```ruby
class WeatherTool < RubyLLM::Tool
  description "Get current weather"
  param :latitude
  param :longitude

  def execute(latitude:, longitude:)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m"
    JSON.parse(Faraday.get(url).body)
  end
end
```

#### Wire into `app/jobs/chat_response_job.rb`

Add after `with_instructions`:

```ruby
chat.with_tool(WeatherTool)
```

### Sub-part B: Todo Model

```bash
bin/rails generate scaffold Todo title:string description:text status:string priority:string category:string due_date:date
bin/rails db:migrate
```

#### `db/seeds.rb`

```ruby
Todo.create!(title: "Buy groceries", description: "Milk, eggs, bread, and coffee", priority: "high", due_date: Date.today)
Todo.create!(title: "Schedule dentist appointment", priority: "medium", due_date: Date.today)
Todo.create!(title: "Read RubyLLM docs", description: "Focus on tools and agents", priority: "low", due_date: 3.days.from_now)
Todo.create!(title: "Prepare workshop demo", description: "Test all code examples", priority: "high", due_date: 1.day.from_now)
Todo.create!(title: "Reply to Sarah's email", priority: "medium")
```

```bash
bin/rails db:seed
```

### Sub-part C: ListTodos Tool

```bash
bin/rails generate ruby_llm:tool ListTodos
```

> **LIVE CODE** — Follow the instructor to implement `app/tools/list_todos_tool.rb`

#### Update system prompt and tools in `app/jobs/chat_response_job.rb`

```ruby
chat.with_instructions(<<~PROMPT)
  You are TaskPilot, an AI task management assistant. You help users
  organize their work and life by managing their todo list.

  Be concise, friendly, and action-oriented. When users describe tasks,
  help them break things down into clear, actionable items.

  Always respond in a helpful, encouraging tone.

  Today's date is #{Date.today} (#{Date.today.strftime("%A")}).
PROMPT

chat.with_tools(WeatherTool, ListTodosTool)
```

### Sub-part D: CreateTodo & CompleteTodo

```bash
bin/rails generate ruby_llm:tool CreateTodo
```

> **LIVE CODE** — Follow the instructor to implement `app/tools/create_todo_tool.rb`

#### Final version of `app/tools/create_todo_tool.rb` (after teaching moments)

```ruby
class CreateTodoTool < RubyLLM::Tool
  description "Creates a new todo item."

  params do
    string :title
    string :description, required: false
    string :priority, enum: %w[low medium high], required: false
    string :due_date, format: "date", required: false
  end

  def execute(title:, description: nil, priority: "medium", due_date: nil)
    todo = Todo.create!(title:, description:, priority:, due_date:, status: "pending")
    "Created todo #{todo.to_json}"
  end
end
```

```bash
bin/rails generate ruby_llm:tool CompleteTodo
```

#### `app/tools/complete_todo_tool.rb`

```ruby
class CompleteTodoTool < RubyLLM::Tool
  description "Marks a todo as completed"
  param :id

  def execute(id:)
    todo = Todo.find_by(id: id)
    if todo.nil?
      "No todo found with id #{id}"
    else
      todo.update!(status: "completed")
      "Completed todo ##{todo.id}: '#{todo.title}'"
    end
  end
end
```

#### Wire all tools in `app/jobs/chat_response_job.rb`

```ruby
chat.with_tools(WeatherTool, ListTodosTool, CreateTodoTool, CompleteTodoTool)
```

> **Checkpoint:** `git checkout part-3-complete`

---

## Part 4: Agents and Orchestration

### Sub-part A: Refactor into TaskPilotAgent

```bash
bin/rails generate ruby_llm:agent TaskPilot
```

#### `app/prompts/task_pilot_agent/instructions.txt.erb`

```erb
You are TaskPilot, an AI task management assistant. You help users
organize their work and life by managing their todo list.

Be concise, friendly, and action-oriented. When users describe tasks,
help them break things down into clear, actionable items.

Always respond in a helpful, encouraging tone.

Today's date is <%= Date.today %> (<%= Date.today.strftime("%A") %>).
```

#### `app/agents/task_pilot_agent.rb`

```ruby
class TaskPilotAgent < RubyLLM::Agent
  chat_model Chat
  instructions
  tools WeatherTool, ListTodosTool, CreateTodoTool, CompleteTodoTool
end
```

#### `app/jobs/chat_response_job.rb` (refactored)

```ruby
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
```

### Instructions Interface

> **LIVE CODE / DEMO** — Follow the instructor. Watch steps 10-12 (no typing).

### Sub-part B: WebSearchAgent

```bash
bin/rails generate ruby_llm:agent WebSearch
```

#### `app/agents/web_search_agent.rb`

```ruby
class WebSearchAgent < RubyLLM::Agent
  chat_model "Chat"
  model "gpt-5-search-api"
end
```

```bash
bin/rails generate ruby_llm:tool WebSearch
```

#### `app/tools/web_search_tool.rb`

```ruby
class WebSearchTool < RubyLLM::Tool
  description "Searches the web for current information. Use this when the user " \
              "needs up-to-date facts, recent news, documentation, or anything " \
              "that requires real-time web access."

  param :query, desc: "The search query"

  def execute(query:)
    WebSearchAgent.create.ask(query).content
  end
end
```

#### `app/agents/task_pilot_agent.rb` (updated)

```ruby
class TaskPilotAgent < RubyLLM::Agent
  chat_model Chat
  instructions
  tools WeatherTool, ListTodosTool, CreateTodoTool, CompleteTodoTool, WebSearchTool
end
```

> **Checkpoint:** `git checkout part-4-complete`

---

## Part 5: Agentic Workflow Patterns

### Pattern 1: Sequential Pipeline

#### `app/jobs/sequential_pipeline_job.rb`

```ruby
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
```

To try it, change `ChatResponseJob` to `SequentialPipelineJob` in both `messages_controller.rb` and `chats_controller.rb`.

### Pattern 2: Fan-Out / Fan-In

```bash
bundle add async
```

#### `bin/code_review.rb`

```ruby
#!/usr/bin/env ruby
require_relative "../config/environment"
require "async"

class SecurityReviewAgent < RubyLLM::Agent
  instructions "Given code, review it for security issues."
end

class PerformanceReviewAgent < RubyLLM::Agent
  instructions "Given code, review it for performance issues."
end

class StyleReviewAgent < RubyLLM::Agent
  instructions "Given code, review style against Ruby conventions."
end

class ReviewSynthesizerAgent < RubyLLM::Agent
  instructions "Given multiple code review reports, summarize prioritized findings."
end

code = ARGV.join(" ").presence || "def calculate(x); x * 2; end"
puts "Reviewing: #{code}\n\n"

result = Async do |task|
  security = task.async do
    puts "Security review starting..."
    result = SecurityReviewAgent.new.ask(code).content
    puts "Security review done."
    result
  end

  performance = task.async do
    puts "Performance review starting..."
    result = PerformanceReviewAgent.new.ask(code).content
    puts "Performance review done."
    result
  end

  style = task.async do
    puts "Style review starting..."
    result = StyleReviewAgent.new.ask(code).content
    puts "Style review done."
    result
  end

  security = security.wait
  performance = performance.wait
  style = style.wait
  puts "Synthesizing..."
  ReviewSynthesizerAgent.new.ask(
    "security: #{security}\n\n" \
    "performance: #{performance}\n\n" \
    "style: #{style}"
  ).content
end.wait

puts "\n#{result}"
```

```bash
ruby bin/code_review.rb "def calculate(x); x * 2; end"
```

---

## Checkpoints

If you fall behind, jump to any checkpoint:

```bash
git checkout part-1-complete   # After Part 1: working chat UI
git checkout part-2-complete   # After Part 2: system prompts
git checkout part-3-complete   # After Part 3: tools
git checkout part-4-complete   # After Part 4: agents, web search

# After switching:
bundle install
bin/rails db:migrate
bin/dev
```

## Resources

- **Docs:** [rubyllm.com](https://rubyllm.com)
- **GitHub:** [github.com/crmne/ruby_llm](https://github.com/crmne/ruby_llm)
- **RubyGems:** `gem install ruby_llm`
