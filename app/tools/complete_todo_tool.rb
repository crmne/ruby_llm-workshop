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
