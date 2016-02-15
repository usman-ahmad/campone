namespace :data do

  # TODO: This task is supposed to run only one time. we may delete this task after running it
  desc "Change enum values to string for priority and progress column (One Time Call)"
  task change_enum_to_string: :environment do
    priority = { nil=> 'None', '0' => 'Low', '1' => 'Medium', '2' => 'High' }
    progress = { '0' => 'No progress', '1' => 'In progress', '2' => 'Completed' }

    Task.find_each do |task|
      task.priority = priority[task.priority]
      task.progress = progress[task.progress]
      task.save!
    end
  end

end
