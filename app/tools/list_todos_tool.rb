class ListTodosTool < RubyLLM::Tool
  description "Lists all todos."

  def execute
    Todo.order(:due_date).to_json
  end
end
