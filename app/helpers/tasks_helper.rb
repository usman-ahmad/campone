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
    ((state == 'Completed') || (state =='Closed'))? state_label  = state.remove('d') : state_label  = state.remove('ed')
  end
end

