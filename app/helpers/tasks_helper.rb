module TasksHelper

  def assigned_to_options(project)
    [['Everybody', 0]] + project.members.collect { |m| [ m.name, m.id ] }
  end

  def task_assigned_to(task)
    case task.assigned_to
      when nil
        'Nobody'
      when 0
        'Everybody'
      else
        User.find(task.assigned_to).name
    end
  end
end
