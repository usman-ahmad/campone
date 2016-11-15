class ModifyProgressesOnTasks < ActiveRecord::Migration[5.0]
  # PROGRESS_MAP = {
  #     NOT_SCHEDULED: 'unscheduled',
  #     NO_PROGRESS: 'unstarted',
  #     IN_PROGRESS: 'started',
  #     PAUSED: 'paused',
  #     COMPLETED: 'finished',
  #     DEPLOYED: 'delivered',
  #     REJECTED: 'rejected',
  #     ACCEPTED: 'accepted',
  #     CLOSED: 'accepted'
  # }
  def up
    change_column_default(:tasks, :progress, 'unscheduled')
    progress_map = {
        'No progress' => 'unstarted',
        'Started' => 'started',
        'In progress' => 'started',
        'Completed' => 'finished',
        'Rejected' => 'rejected ',
        'Accepted' => 'accepted',
        'Deployed' => 'delivered',
        'Closed' => 'accepted'
    }
    Task.find_each do |task|
      task.update_column :progress, progress_map[task.progress]
    end
  end

  def down
    change_column_default(:tasks, :progress, 'No progress')
    progress_map = {
        'unscheduled' => 'No progress',
        'unstarted' => 'No progress',
        'started' => 'In progress',
        'paused' => 'In progress',
        'finished' => 'Completed',
        'delivered' => 'Deployed',
        'rejected' => 'Rejected',
        'accepted' => 'Closed'
    }
    Task.find_each do |task|
      task.update_column :progress, progress_map[task.progress]
    end
  end
end
