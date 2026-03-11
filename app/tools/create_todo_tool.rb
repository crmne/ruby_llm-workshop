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
