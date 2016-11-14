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

  def state_label(state)
     if state == Task::PROGRESSES[:COMPLETED] || state == Task::PROGRESSES[:CLOSED]
       state.remove('d')
     else
       state.remove('ed')
     end
  end
end
